#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define HQ (-1)
#define NEG (-1.0e100)

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef struct {
    int x, y, p;
    double r, ang, key;
    unsigned morton;
} City;

typedef struct {
    int *seq;
    int *st;
    int *len;
    int seqN, seqCap;
    int tripN, tripCap;
    double profit;
} Route;

static int N, T;
static double C, D;
static City *city;
static double rateDecline[64];

static int *ordArr;
static int *baseArr;
static int *stackArr;
static int *candArr;
static int *activeArr;
static double *dp;
static int *pre;
static int *plen;

static clock_t startClock;
static double softLimitSec;

static int time_ok(void) {
    double used = (double)(clock() - startClock) / (double)CLOCKS_PER_SEC;
    return used < softLimitSec;
}

static double dist_id(int a, int b) {
    double ax = 0.0, ay = 0.0, bx = 0.0, by = 0.0;

    if (a != HQ) {
        ax = city[a].x;
        ay = city[a].y;
    }

    if (b != HQ) {
        bx = city[b].x;
        by = city[b].y;
    }

    double dx = ax - bx;
    double dy = ay - by;

    return sqrt(dx * dx + dy * dy);
}

static double sale_rate(int sold_before) {
    int b = sold_before / T;

    if (b < 0) b = 0;
    if (b > 63) b = 63;

    return rateDecline[b];
}

static unsigned part1by1(unsigned x) {
    x &= 0x0000ffffu;
    x = (x | (x << 8)) & 0x00ff00ffu;
    x = (x | (x << 4)) & 0x0f0f0f0fu;
    x = (x | (x << 2)) & 0x33333333u;
    x = (x | (x << 1)) & 0x55555555u;
    return x;
}

static unsigned make_morton(int x, int y) {
    unsigned xx = (unsigned)(x + 32768);
    unsigned yy = (unsigned)(y + 32768);

    return part1by1(xx) | (part1by1(yy) << 1);
}

static int cmp_key_desc(const void *A, const void *B) {
    int a = *(const int*)A;
    int b = *(const int*)B;

    if (city[a].key < city[b].key) return 1;
    if (city[a].key > city[b].key) return -1;

    if (city[a].p < city[b].p) return 1;
    if (city[a].p > city[b].p) return -1;

    if (city[a].r < city[b].r) return -1;
    if (city[a].r > city[b].r) return 1;

    return a - b;
}

static int cmp_angle(const void *A, const void *B) {
    int a = *(const int*)A;
    int b = *(const int*)B;

    if (city[a].ang < city[b].ang) return -1;
    if (city[a].ang > city[b].ang) return 1;

    if (city[a].r < city[b].r) return -1;
    if (city[a].r > city[b].r) return 1;

    if (city[a].p < city[b].p) return 1;
    if (city[a].p > city[b].p) return -1;

    return a - b;
}

static int cmp_morton(const void *A, const void *B) {
    int a = *(const int*)A;
    int b = *(const int*)B;

    if (city[a].morton < city[b].morton) return -1;
    if (city[a].morton > city[b].morton) return 1;

    if (city[a].p < city[b].p) return 1;
    if (city[a].p > city[b].p) return -1;

    return a - b;
}

static int cmp_radius(const void *A, const void *B) {
    int a = *(const int*)A;
    int b = *(const int*)B;

    if (city[a].r < city[b].r) return -1;
    if (city[a].r > city[b].r) return 1;

    if (city[a].p < city[b].p) return 1;
    if (city[a].p > city[b].p) return -1;

    return a - b;
}

static void route_init(Route *r) {
    r->seq = NULL;
    r->st = NULL;
    r->len = NULL;
    r->seqN = 0;
    r->seqCap = 0;
    r->tripN = 0;
    r->tripCap = 0;
    r->profit = 0.0;
}

static void route_clear(Route *r) {
    r->seqN = 0;
    r->tripN = 0;
    r->profit = 0.0;
}

static void route_free(Route *r) {
    free(r->seq);
    free(r->st);
    free(r->len);
    route_init(r);
}

static void ensure_seq(Route *r, int need) {
    if (need <= r->seqCap) return;

    int nc = r->seqCap ? r->seqCap * 2 : 256;

    while (nc < need) nc *= 2;

    r->seq = (int*)realloc(r->seq, sizeof(int) * nc);
    r->seqCap = nc;
}

static void ensure_trip(Route *r, int need) {
    if (need <= r->tripCap) return;

    int nc = r->tripCap ? r->tripCap * 2 : 128;

    while (nc < need) nc *= 2;

    r->st = (int*)realloc(r->st, sizeof(int) * nc);
    r->len = (int*)realloc(r->len, sizeof(int) * nc);
    r->tripCap = nc;
}

static void route_add(Route *r, const int *ids, int len) {
    if (len <= 0) return;

    ensure_trip(r, r->tripN + 1);
    ensure_seq(r, r->seqN + len);

    r->st[r->tripN] = r->seqN;
    r->len[r->tripN] = len;

    memcpy(r->seq + r->seqN, ids, sizeof(int) * len);

    r->seqN += len;
    r->tripN++;
}

static void route_copy(Route *dst, const Route *src) {
    ensure_seq(dst, src->seqN);
    ensure_trip(dst, src->tripN);

    memcpy(dst->seq, src->seq, sizeof(int) * src->seqN);
    memcpy(dst->st, src->st, sizeof(int) * src->tripN);
    memcpy(dst->len, src->len, sizeof(int) * src->tripN);

    dst->seqN = src->seqN;
    dst->tripN = src->tripN;
    dst->profit = src->profit;
}

static double eval_trip_ids(const int *ids, int len, int sold0, int needReturn) {
    double ans = 0.0;
    int prev = HQ;
    int rem = len;

    for (int i = 0; i < len; ++i) {
        int id = ids[i];
        double d = dist_id(prev, id);

        ans -= d * (1.0 + C * rem);
        ans += city[id].p * sale_rate(sold0 + i);

        prev = id;
        rem--;
    }

    if (needReturn && len > 0) {
        ans -= city[prev].r;
    }

    return ans;
}

static double eval_route(Route *r) {
    double ans = 0.0;
    int sold = 0;

    for (int t = 0; t < r->tripN; ++t) {
        int needReturn = (t + 1 < r->tripN);
        int st = r->st[t];
        int len = r->len[t];

        ans += eval_trip_ids(r->seq + st, len, sold, needReturn);
        sold += len;
    }

    r->profit = ans;

    return ans;
}

static int choose_max_trip_len(void) {
    int k;

    if (C >= 4.0) {
        k = 4;
    } else if (C >= 2.0) {
        k = 6;
    } else if (C >= 1.0) {
        k = 10;
    } else if (C >= 0.45) {
        k = 16;
    } else if (C >= 0.15) {
        k = 28;
    } else if (C >= 0.05) {
        k = 45;
    } else {
        k = 80;
    }

    if (N <= 2000 && k < 90) k = 90;
    if (N <= 10000 && k < 55) k = 55;
    if (N >= 40000 && k > 32) k = 32;
    if (N >= 70000 && k > 26) k = 26;
    if (k > N) k = N;

    return k;
}

static int choose_final_trip_len(int maxK) {
    int k = maxK * 2;

    if (C < 0.05) {
        k = maxK * 5;
    } else if (C < 0.15) {
        k = maxK * 3;
    }

    if (N <= 2000 && C < 0.20) k = N;
    if (N <= 10000 && C < 0.08 && k < 180) k = 180;
    if (N >= 40000 && k > 90) k = 90;
    if (N >= 70000 && k > 70) k = 70;
    if (k < maxK) k = maxK;
    if (k > N) k = N;

    return k;
}

static void build_base_order(double alpha, int ratioMode) {
    for (int i = 0; i < N; ++i) {
        if (ratioMode) {
            city[i].key = (double)city[i].p / (1.0 + alpha * city[i].r);
        } else {
            city[i].key = (double)city[i].p - alpha * city[i].r;
        }

        baseArr[i] = i;
    }

    qsort(baseArr, N, sizeof(int), cmp_key_desc);
}

static int build_candidate_order(double filterMul, int maxTake) {
    int m = 0;

    for (int i = 0; i < N; ++i) {
        int id = baseArr[i];

        if (filterMul > 0.0) {
            double singleApprox = (1.0 + C) * city[id].r;

            if ((double)city[id].p <= filterMul * singleApprox) {
                continue;
            }
        }

        ordArr[m++] = id;

        if (maxTake > 0 && m >= maxTake) {
            break;
        }
    }

    return m;
}

static void sort_windows(int m, int window, int mode, int reverseOdd) {
    if (window < 1) window = 1;

    for (int s = 0; s < m; s += window) {
        int len = window;

        if (s + len > m) len = m - s;

        if (mode == 1) {
            qsort(ordArr + s, len, sizeof(int), cmp_morton);
        } else if (mode == 2) {
            qsort(ordArr + s, len, sizeof(int), cmp_angle);
        } else if (mode == 3) {
            qsort(ordArr + s, len, sizeof(int), cmp_radius);
        }

        if (reverseOdd && ((s / window) & 1)) {
            for (int l = 0, r = len - 1; l < r; ++l, --r) {
                int tmp = ordArr[s + l];
                ordArr[s + l] = ordArr[s + r];
                ordArr[s + r] = tmp;
            }
        }
    }
}

static void solve_order(Route *cur, int m, int maxK, int maxFinalK) {
    route_clear(cur);

    if (m <= 0) return;
    if (maxK > m) maxK = m;
    if (maxFinalK > m) maxFinalK = m;
    if (maxFinalK < maxK) maxFinalK = maxK;

    for (int i = 0; i <= m; ++i) {
        dp[i] = NEG;
        pre[i] = -1;
        plen[i] = 0;
    }

    dp[0] = 0.0;

    double bestVal = 0.0;
    int finalStart = -1;
    int finalLen = 0;

    for (int i = 0; i < m; ++i) {
        if (!time_ok()) return;
        if (dp[i] <= NEG * 0.5) continue;

        double noReturn = 0.0;
        double pathLen = 0.0;
        int prevId = HQ;

        int lim = maxFinalK;
        if (i + lim > m) lim = m - i;

        for (int l = 1; l <= lim; ++l) {
            int id = ordArr[i + l - 1];
            double d = dist_id(prevId, id);

            noReturn += city[id].p * sale_rate(i + l - 1);
            noReturn -= C * pathLen;
            noReturn -= (1.0 + C) * d;

            pathLen += d;
            prevId = id;

            int j = i + l;

            if (l <= maxK) {
                double withReturn = noReturn - city[id].r;
                double cand = dp[i] + withReturn;

                if (cand > dp[j]) {
                    dp[j] = cand;
                    pre[j] = i;
                    plen[j] = l;
                }
            }

            double cand = dp[i] + noReturn;

            if (cand > bestVal) {
                bestVal = cand;
                finalStart = i;
                finalLen = l;
            }
        }
    }

    if (finalStart < 0 || finalLen <= 0) return;

    int cnt = 0;
    int pos = finalStart;

    while (pos > 0 && pre[pos] >= 0) {
        stackArr[cnt++] = pos;
        pos = pre[pos];
    }

    for (int i = cnt - 1; i >= 0; --i) {
        int end = stackArr[i];
        int st = pre[end];
        int len = plen[end];

        route_add(cur, ordArr + st, len);
    }

    route_add(cur, ordArr + finalStart, finalLen);
    eval_route(cur);
}

static void maybe_best(Route *best, Route *cur) {
    if (cur->tripN > 0 && cur->profit > best->profit) {
        route_copy(best, cur);
    }
}

static void run_variant(Route *best, Route *cur, double alpha, int ratioMode, double filterMul, int window, int mode, int rev, int maxK, int maxFinalK, int maxTake) {
    if (!time_ok()) return;

    build_base_order(alpha, ratioMode);

    if (!time_ok()) return;

    int m = build_candidate_order(filterMul, maxTake);

    if (m <= 0) return;

    if (mode != 0) {
        sort_windows(m, window, mode, rev);
    }

    if (!time_ok()) return;

    solve_order(cur, m, maxK, maxFinalK);
    maybe_best(best, cur);
}

static int build_greedy_spatial_order(double filterMul, int maxTake, int front, double distMul, double retMul, int loadProxy) {
    int m = build_candidate_order(filterMul, maxTake);

    if (m <= 0) return 0;

    memcpy(candArr, ordArr, sizeof(int) * m);

    if (front < 1) front = 1;
    if (front > m) front = m;
    if (loadProxy < 1) loadProxy = 1;

    int activeN = 0;
    int next = 0;

    while (activeN < front && next < m) {
        activeArr[activeN++] = candArr[next++];
    }

    int prev = HQ;

    for (int out = 0; out < m && activeN > 0; ++out) {
        if (!time_ok()) return out;

        int bestPos = 0;
        double bestScore = NEG;
        double rate = sale_rate(out);

        for (int i = 0; i < activeN; ++i) {
            int id = activeArr[i];
            double d = dist_id(prev, id);
            double score = (double)city[id].p * rate;

            score -= distMul * d * (1.0 + C * loadProxy);
            score -= retMul * city[id].r;

            if (score > bestScore) {
                bestScore = score;
                bestPos = i;
            }
        }

        int id = activeArr[bestPos];
        ordArr[out] = id;
        prev = id;

        if (next < m) {
            activeArr[bestPos] = candArr[next++];
        } else {
            activeArr[bestPos] = activeArr[--activeN];
        }
    }

    return m;
}

static void run_greedy_variant(Route *best, Route *cur, double alpha, int ratioMode, double filterMul, int front, double distMul, double retMul, int maxK, int maxFinalK, int maxTake) {
    if (!time_ok()) return;

    build_base_order(alpha, ratioMode);

    if (!time_ok()) return;

    int loadProxy = maxK;
    if (loadProxy > 40) loadProxy = 40;
    if (loadProxy < 3) loadProxy = 3;

    int m = build_greedy_spatial_order(filterMul, maxTake, front, distMul, retMul, loadProxy);

    if (m <= 0) return;

    solve_order(cur, m, maxK, maxFinalK);
    maybe_best(best, cur);
}

static void reorder_trip_fast(int *ids, int len, int sold0, int needReturn) {
    if (len <= 2 || len > 80) return;

    int *tmp = (int*)malloc(sizeof(int) * len);
    char *used = (char*)calloc(len, 1);

    if (!tmp || !used) {
        free(tmp);
        free(used);
        return;
    }

    int prev = HQ;

    for (int pos = 0; pos < len; ++pos) {
        int best = -1;
        double bestScore = NEG;
        int rem = len - pos;

        for (int j = 0; j < len; ++j) {
            if (used[j]) continue;

            int id = ids[j];
            double d = dist_id(prev, id);
            double score = city[id].p * sale_rate(sold0 + pos) - d * (1.0 + C * rem);

            if (needReturn && pos == len - 1) {
                score -= city[id].r;
            }

            if (score > bestScore) {
                bestScore = score;
                best = j;
            }
        }

        tmp[pos] = ids[best];
        used[best] = 1;
        prev = tmp[pos];
    }

    double oldVal = eval_trip_ids(ids, len, sold0, needReturn);
    double newVal = eval_trip_ids(tmp, len, sold0, needReturn);

    if (newVal > oldVal) {
        memcpy(ids, tmp, sizeof(int) * len);
    }

    free(used);
    free(tmp);
}

static void improve_trip_swaps_small(int *ids, int len, int sold0, int needReturn) {
    if (len <= 2 || len > 45) return;

    double bestVal = eval_trip_ids(ids, len, sold0, needReturn);

    for (int pass = 0; pass < 2; ++pass) {
        int changed = 0;

        for (int i = 0; i < len - 1; ++i) {
            if (!time_ok()) return;

            for (int j = i + 1; j < len; ++j) {
                int a = ids[i];
                ids[i] = ids[j];
                ids[j] = a;

                double v = eval_trip_ids(ids, len, sold0, needReturn);

                if (v > bestVal + 1e-9) {
                    bestVal = v;
                    changed = 1;
                } else {
                    a = ids[i];
                    ids[i] = ids[j];
                    ids[j] = a;
                }
            }
        }

        if (!changed) break;
    }
}

static void resegment_best(Route *best, Route *cur, int maxK, int maxFinalK) {
    if (!time_ok()) return;
    if (best->seqN <= 0) return;

    memcpy(ordArr, best->seq, sizeof(int) * best->seqN);
    solve_order(cur, best->seqN, maxK, maxFinalK);
    maybe_best(best, cur);
}

static void improve_best_fast(Route *best) {
    if (!time_ok()) return;

    Route cur;
    route_init(&cur);
    route_copy(&cur, best);

    int sold = 0;

    for (int t = 0; t < cur.tripN; ++t) {
        if (!time_ok()) break;

        int st = cur.st[t];
        int len = cur.len[t];
        int needReturn = (t + 1 < cur.tripN);

        reorder_trip_fast(cur.seq + st, len, sold, needReturn);
        improve_trip_swaps_small(cur.seq + st, len, sold, needReturn);
        sold += len;
    }

    eval_route(&cur);

    if (cur.profit > best->profit) {
        route_copy(best, &cur);
    }

    route_free(&cur);
}

static void make_single_fallback(Route *best) {
    if (best->tripN > 0 && best->profit > 0.0) return;

    int bestId = 0;
    double bestVal = city[0].p - (1.0 + C) * city[0].r;

    for (int i = 1; i < N; ++i) {
        double val = city[i].p - (1.0 + C) * city[i].r;

        if (val > bestVal) {
            bestVal = val;
            bestId = i;
        }
    }

    route_clear(best);
    route_add(best, &bestId, 1);
    eval_route(best);
}

static void print_route(const Route *r) {
    if (r->tripN <= 0) return;

    for (int t = 0; t < r->tripN; ++t) {
        if (t > 0) {
            printf("0 0\n");
        }

        int st = r->st[t];
        int len = r->len[t];

        for (int i = 0; i < len; ++i) {
            int id = r->seq[st + i];

            if (i == 0) {
                printf("%d %d %d\n", city[id].x, city[id].y, len);
            } else {
                printf("%d %d\n", city[id].x, city[id].y);
            }
        }
    }
}

int main(void) {
    startClock = clock();

    if (scanf("%d %lf %lf", &N, &C, &D) != 3) {
        return 0;
    }

    if (N <= 0) return 0;

    if (N >= 70000) {
        softLimitSec = 1.82;
    } else if (N >= 40000) {
        softLimitSec = 1.84;
    } else if (N >= 15000) {
        softLimitSec = 1.86;
    } else {
        softLimitSec = 1.88;
    }

    T = N / 10;
    if (T <= 0) T = 1;

    city = (City*)malloc(sizeof(City) * N);
    ordArr = (int*)malloc(sizeof(int) * N);
    baseArr = (int*)malloc(sizeof(int) * N);
    stackArr = (int*)malloc(sizeof(int) * (N + 1));
    candArr = (int*)malloc(sizeof(int) * N);
    activeArr = (int*)malloc(sizeof(int) * N);
    dp = (double*)malloc(sizeof(double) * (N + 1));
    pre = (int*)malloc(sizeof(int) * (N + 1));
    plen = (int*)malloc(sizeof(int) * (N + 1));

    if (!city || !ordArr || !baseArr || !stackArr || !candArr || !activeArr || !dp || !pre || !plen) {
        return 0;
    }

    for (int i = 0; i < N; ++i) {
        scanf("%d %d %d", &city[i].x, &city[i].y, &city[i].p);

        city[i].r = sqrt((double)city[i].x * city[i].x + (double)city[i].y * city[i].y);
        city[i].ang = atan2((double)city[i].y, (double)city[i].x);
        city[i].morton = make_morton(city[i].x, city[i].y);
        city[i].key = 0.0;
    }

    rateDecline[0] = 1.0;

    for (int i = 1; i < 64; ++i) {
        rateDecline[i] = rateDecline[i - 1] * D;
    }

    Route best;
    Route cur;

    route_init(&best);
    route_init(&cur);

    best.profit = 0.0;

    int maxK = choose_max_trip_len();
    int maxFinalK = choose_final_trip_len(maxK);

    int w = T;
    if (w < 300) w = 300;
    if (w > 8000) w = 8000;

    int w2 = w / 2;
    if (w2 < 150) w2 = 150;

    int maxTake = 0;

    if (N >= 50000) {
        maxTake = 50000;
    }

    run_variant(&best, &cur, 0.0, 0, 0.0, w, 0, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 1.0 + C, 0, 0.0, w, 0, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 0.50, 0, 0.15, w, 1, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 1.0 + C, 0, 0.20, w, 1, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 1.0 + C, 0, 0.20, w, 2, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 2.0 + C, 0, 0.35, w, 2, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 0.01, 1, 0.0, w, 0, 0, maxK, maxFinalK, maxTake);
    run_variant(&best, &cur, 0.02, 1, 0.20, w, 1, 0, maxK, maxFinalK, maxTake);

    run_greedy_variant(&best, &cur, 1.0 + C, 0, 0.10, 96, 0.35, 0.05, maxK, maxFinalK, maxTake);
    run_greedy_variant(&best, &cur, 0.02, 1, 0.05, 128, 0.25, 0.02, maxK, maxFinalK, maxTake);

    if (N < 40000) {
        run_variant(&best, &cur, 0.25, 0, 0.0, w, 2, 0, maxK, maxFinalK, maxTake);
        run_variant(&best, &cur, 0.75, 0, 0.10, w, 1, 1, maxK, maxFinalK, maxTake);
        run_variant(&best, &cur, 4.0 + C, 0, 0.50, w, 3, 0, maxK, maxFinalK, maxTake);
        run_variant(&best, &cur, 0.035, 1, 0.15, w2, 2, 1, maxK, maxFinalK, maxTake);
        run_greedy_variant(&best, &cur, 0.75, 0, 0.00, 192, 0.20, 0.00, maxK, maxFinalK, maxTake);
        run_greedy_variant(&best, &cur, 2.0 + C, 0, 0.20, 160, 0.45, 0.06, maxK, maxFinalK, maxTake);
    }

    improve_best_fast(&best);
    resegment_best(&best, &cur, maxK, maxFinalK);
    make_single_fallback(&best);
    print_route(&best);

    route_free(&best);
    route_free(&cur);

    free(plen);
    free(pre);
    free(dp);
    free(activeArr);
    free(candArr);
    free(stackArr);
    free(baseArr);
    free(ordArr);
    free(city);

    return 0;
}
