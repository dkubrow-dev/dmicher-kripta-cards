#define EXACT_TRIP_MAX 12
#define PROBE_LOW_N 40001
#define PROBE_HIGH_N 2147483647
#define PROBE_BLOCK_LOW_N 40001
#define PROBE_BLOCK_HIGH_N 50000
#define PROBE_EXACT_BUDGET_CAP_BLOCK 100000000LL
#define PROBE_EXACT_BUDGET_CAP_50K 600000000LL
#define PROBE_EXACT_BUDGET_CAP_AFTER_BLOCK 600000000LL
#define PROBE_PROFILE 64
/* cpu-optimized exact DP; p52 after50000 cap600 */

#define _CRT_SECURE_NO_WARNINGS

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define LEVELS 10
#define GRID 128
#define INF 1e100
#define EPS 1e-9
#define TWO_PI 6.28318530717958647692
#ifndef PROBE_LOW_N
#define PROBE_LOW_N 50001
#endif
#ifndef PROBE_HIGH_N
#define PROBE_HIGH_N 2147483647
#endif
#ifndef PROBE_BLOCK_LOW_N
#define PROBE_BLOCK_LOW_N 40001
#endif
#ifndef PROBE_BLOCK_HIGH_N
#define PROBE_BLOCK_HIGH_N 50000
#endif
#ifndef PROBE_EXACT_BUDGET
#define PROBE_EXACT_BUDGET 1200000000LL
#endif
#ifndef PROBE_EXACT_BUDGET_CAP
#define PROBE_EXACT_BUDGET_CAP 0LL
#endif
#ifndef PROBE_EXACT_BUDGET_CAP_BLOCK
#define PROBE_EXACT_BUDGET_CAP_BLOCK 0LL
#endif
#ifndef PROBE_EXACT_BUDGET_CAP_50K
#define PROBE_EXACT_BUDGET_CAP_50K 0LL
#endif
#ifndef PROBE_EXACT_BUDGET_CAP_AFTER_BLOCK
#define PROBE_EXACT_BUDGET_CAP_AFTER_BLOCK 0LL
#endif
#ifndef PROBE_PROFILE
#define PROBE_PROFILE 3
#endif
// The maximum size of a trip segment for which we perform exact optimization.
// For very large instances, using a high limit here can lead to excessive
// computation and memory use, which may cause some testcases to time out. We
// keep the compileвЂ‘time limit reasonably high so that the local arrays used in
// exact optimisation have sufficient size, but we choose the effective limit
// dynamically at runtime based on the total number of cities. See
// `global_trip_max` below.
#ifndef EXACT_TRIP_MAX
#define EXACT_TRIP_MAX 14
#endif

typedef struct {
    double x, y, p, r, ang;
    char xs[64], ys[64];
    int cell;
    int angle96;
    unsigned int morton, hilbert;
    unsigned char used;
} City;

typedef struct {
    int *ids;
    int count;
    int fill;
    int cursor;
} Cell;

typedef struct {
    double m, b;
    int id;
    unsigned int gen;
} Line;

typedef struct {
    double value;
    int id;
} Query;

typedef struct {
    double profit;
    int visits;
    int final_l;
} Eval;

typedef struct {
    int l, r;
    double key;
    double tie;
} TripBlock;

typedef struct {
    int bucket;
    double key;
    double tie;
} ProbeBucket;

typedef struct {
    int left, right, parent;
    int begin, end;
    int full_count;
    int active_count;
    double minx, maxx, miny, maxy;
    double min_r, max_r;
    double max_p;
} KDNode;

typedef struct {
    unsigned long long visited_nodes;
    unsigned long long checked_points;
    unsigned long long sqrt_evaluations;
    unsigned long long prune_count;
} KDPerfStats;

static City *cities;
static Cell *cells;
static KDNode *kd_nodes;
static int *kd_city_node;
static int *kd_ids;
static int kd_root = -1;
static int kd_count;
static int kd_subset_n;
static int n, block_size;
static int hq_city = -1;
static double carry_cost, drop_factor;
static double factors[LEVELS];

static double *pref_s;
static double *pref_t;
static double *dp;
static int *parent_ret;
static Line *tree;
static int tree_xmax;
static unsigned int lichao_epoch = 1u;
static unsigned char *solver_starts;
static unsigned char *solver_best_starts;
static unsigned int *solver_active_marks;
static unsigned int *solver_taken_marks;
static unsigned int *solver_local_cell_marks;
static TripBlock *solver_trip_blocks;
static double *solver_exact_tdp;
static signed char *solver_exact_par;
static int *solver_local_cell_ids;
static int *solver_local_cell_offsets;
static int *solver_local_cell_counts;
static int *solver_local_cell_touched;
static int solver_workspace_n;
static unsigned int solver_mark_epoch = 1u;
static unsigned int solver_local_cell_epoch = 1u;
static int solver_best_cache_valid;
static int *solver_best_cache_order_ptr;
static Eval solver_best_cache_eval;

static Eval evaluate_order(int *order, int keep_parents);
static void reconstruct_starts(int *order, Eval best, unsigned char *starts);

static double cmp_alpha;
static int cmp_mode;
static int spatial_mode;
static double spatial_angle_offset;
static int deep_trip_polish;
static int *probe_bucket_rank;
static int probe_angle_bins;
static int probe_radius_bins;
static int probe_offset;
static int probe_reverse_radius;
static int probe_inner_mode;
static int kd_perf_enabled;
static KDPerfStats kd_perf_stats;

// The effective upper bound on the size of a trip segment for which we will
// attempt exact optimisation. This value is derived at runtime from the
// instance size (n). Keeping it lower for very large instances avoids
// excessive dynamic programming work. It must never exceed EXACT_TRIP_MAX.
static int global_trip_max = EXACT_TRIP_MAX;

static double g_start_time;
static const double g_time_limit = 1.95;

static int time_ok(double fraction) {
    double elapsed = (double)clock() / (double)CLOCKS_PER_SEC - g_start_time;
    return elapsed < g_time_limit * (1.0 - fraction);
}

static void release_solver_workspace(void) {
    free(solver_starts);
    free(solver_best_starts);
    free(solver_active_marks);
    free(solver_taken_marks);
    free(solver_local_cell_marks);
    free(solver_trip_blocks);
    free(solver_exact_tdp);
    free(solver_exact_par);
    free(solver_local_cell_ids);
    free(solver_local_cell_offsets);
    free(solver_local_cell_counts);
    free(solver_local_cell_touched);
    solver_starts = NULL;
    solver_best_starts = NULL;
    solver_active_marks = NULL;
    solver_taken_marks = NULL;
    solver_local_cell_marks = NULL;
    solver_trip_blocks = NULL;
    solver_exact_tdp = NULL;
    solver_exact_par = NULL;
    solver_local_cell_ids = NULL;
    solver_local_cell_offsets = NULL;
    solver_local_cell_counts = NULL;
    solver_local_cell_touched = NULL;
    solver_workspace_n = 0;
    solver_mark_epoch = 1u;
    solver_local_cell_epoch = 1u;
    solver_best_cache_valid = 0;
    solver_best_cache_order_ptr = NULL;
}

static void ensure_solver_workspace(void) {
    size_t exact_cells = (size_t)((1 << EXACT_TRIP_MAX) * EXACT_TRIP_MAX);
    size_t total_cells = (size_t)(GRID * GRID);
    if (solver_workspace_n == n &&
        solver_starts && solver_active_marks && solver_taken_marks &&
        solver_local_cell_marks && solver_trip_blocks &&
        solver_exact_tdp && solver_exact_par &&
        solver_local_cell_ids && solver_local_cell_offsets &&
        solver_local_cell_counts && solver_local_cell_touched) {
        return;
    }

    release_solver_workspace();
    solver_starts = (unsigned char *)calloc((size_t)n, sizeof(unsigned char));
    solver_best_starts = (unsigned char *)calloc((size_t)n, sizeof(unsigned char));
    solver_active_marks = (unsigned int *)calloc((size_t)n, sizeof(unsigned int));
    solver_taken_marks = (unsigned int *)calloc((size_t)n, sizeof(unsigned int));
    solver_local_cell_marks = (unsigned int *)calloc(total_cells, sizeof(unsigned int));
    solver_trip_blocks = (TripBlock *)malloc((size_t)(n + 1) * sizeof(TripBlock));
    solver_exact_tdp = (double *)malloc(exact_cells * sizeof(double));
    solver_exact_par = (signed char *)malloc(exact_cells * sizeof(signed char));
    solver_local_cell_ids = (int *)malloc((size_t)n * sizeof(int));
    solver_local_cell_offsets = (int *)malloc(total_cells * sizeof(int));
    solver_local_cell_counts = (int *)malloc(total_cells * sizeof(int));
    solver_local_cell_touched = (int *)malloc(total_cells * sizeof(int));
    if (!solver_starts || !solver_best_starts ||
        !solver_active_marks || !solver_taken_marks ||
        !solver_local_cell_marks || !solver_trip_blocks ||
        !solver_exact_tdp || !solver_exact_par ||
        !solver_local_cell_ids || !solver_local_cell_offsets ||
        !solver_local_cell_counts || !solver_local_cell_touched) {
        exit(1);
    }
    solver_workspace_n = n;
    solver_mark_epoch = 1u;
    solver_local_cell_epoch = 1u;
    solver_best_cache_valid = 0;
    solver_best_cache_order_ptr = NULL;
}

static void solver_next_mark_pair(unsigned int *active_tag, unsigned int *taken_tag) {
    ensure_solver_workspace();
    if (solver_mark_epoch >= 0xfffffffeu) {
        memset(solver_active_marks, 0, (size_t)n * sizeof(unsigned int));
        memset(solver_taken_marks, 0, (size_t)n * sizeof(unsigned int));
        solver_mark_epoch = 1u;
    }
    *active_tag = solver_mark_epoch++;
    *taken_tag = solver_mark_epoch++;
}

static void solver_invalidate_best_cache(void) {
    solver_best_cache_valid = 0;
    solver_best_cache_order_ptr = NULL;
}

static unsigned int solver_next_local_cell_tag(void) {
    ensure_solver_workspace();
    if (solver_local_cell_epoch >= 0xfffffffeu) {
        memset(solver_local_cell_marks, 0, (size_t)(GRID * GRID) * sizeof(unsigned int));
        solver_local_cell_epoch = 1u;
    }
    return solver_local_cell_epoch++;
}

static void solver_refresh_best_cache(int *best_order) {
    ensure_solver_workspace();
    solver_best_cache_eval = evaluate_order(best_order, 1);
    reconstruct_starts(best_order, solver_best_cache_eval, solver_best_starts);
    solver_best_cache_order_ptr = best_order;
    solver_best_cache_valid = 1;
}

static inline int visit_level(int pos) {
    int level;
    if (n <= 0) return 0;
    level = (int)(((long long)pos * LEVELS) / n);
    if (level < 0) return 0;
    if (level >= LEVELS) return LEVELS - 1;
    return level;
}

static int probe_in_range(void) {
    return n >= PROBE_LOW_N && n <= PROBE_HIGH_N;
}

static int city_angle_bucket(int id, int bins, int offset);
static int radius_bucket(double r, int bins, int reverse);
static void reconstruct_starts(int *order, Eval best, unsigned char *starts);

static inline double dist2d(double ax, double ay, double bx, double by) {
    double dx = ax - bx;
    double dy = ay - by;
    return sqrt(dx * dx + dy * dy);
}

static int coord_cell(double v) {
    int c = (int)((v + 1000.0) * ((double)GRID / 2000.0));
    if (c < 0) return 0;
    if (c >= GRID) return GRID - 1;
    return c;
}

static int cell_id_xy(int gx, int gy) {
    return gy * GRID + gx;
}

static int city_cell(double x, double y) {
    return cell_id_xy(coord_cell(x), coord_cell(y));
}

static unsigned int part_bits(unsigned int x) {
    x &= 0x0000ffffu;
    x = (x | (x << 8)) & 0x00ff00ffu;
    x = (x | (x << 4)) & 0x0f0f0f0fu;
    x = (x | (x << 2)) & 0x33333333u;
    x = (x | (x << 1)) & 0x55555555u;
    return x;
}

static unsigned int morton_code(double x, double y) {
    unsigned int xi = (unsigned int)(coord_cell(x) * 512 + 256);
    unsigned int yi = (unsigned int)(coord_cell(y) * 512 + 256);
    return (part_bits(yi) << 1) | part_bits(xi);
}

static void hilbert_rot(unsigned int nside, unsigned int *x, unsigned int *y,
                        unsigned int rx, unsigned int ry) {
    if (ry == 0) {
        if (rx == 1) {
            *x = nside - 1 - *x;
            *y = nside - 1 - *y;
        }
        unsigned int t = *x;
        *x = *y;
        *y = t;
    }
}

static unsigned int hilbert_code(double x, double y) {
    unsigned int xi = (unsigned int)coord_cell(x);
    unsigned int yi = (unsigned int)coord_cell(y);
    unsigned int d = 0;
    for (unsigned int s = GRID / 2; s > 0; s >>= 1) {
        unsigned int rx = (xi & s) ? 1u : 0u;
        unsigned int ry = (yi & s) ? 1u : 0u;
        d += s * s * ((3u * rx) ^ ry);
        hilbert_rot(s, &xi, &yi, rx, ry);
    }
    return d;
}

static double start_score(int id, double alpha) {
    return cities[id].p - alpha * cities[id].r;
}

static int cmp_city_ids(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;

    double va, vb;
    if (cmp_mode == 0) {
        va = start_score(ia, cmp_alpha);
        vb = start_score(ib, cmp_alpha);
    } else if (cmp_mode == 1) {
        va = cities[ia].p;
        vb = cities[ib].p;
    } else if (cmp_mode == 2) {
        va = cities[ia].p / (1.0 + cities[ia].r);
        vb = cities[ib].p / (1.0 + cities[ib].r);
    } else {
        if (cities[ia].morton < cities[ib].morton) return -1;
        if (cities[ia].morton > cities[ib].morton) return 1;
        va = cities[ia].p;
        vb = cities[ib].p;
    }

    if (va < vb) return 1;
    if (va > vb) return -1;
    if (cities[ia].p < cities[ib].p) return 1;
    if (cities[ia].p > cities[ib].p) return -1;
    return ia - ib;
}

static int cmp_x_ids(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;
    if (cities[ia].x + EPS < cities[ib].x) return -1;
    if (cities[ia].x > cities[ib].x + EPS) return 1;
    if (cities[ia].y + EPS < cities[ib].y) return -1;
    if (cities[ia].y > cities[ib].y + EPS) return 1;
    return ia - ib;
}

static int cmp_y_ids(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;
    if (cities[ia].y + EPS < cities[ib].y) return -1;
    if (cities[ia].y > cities[ib].y + EPS) return 1;
    if (cities[ia].x + EPS < cities[ib].x) return -1;
    if (cities[ia].x > cities[ib].x + EPS) return 1;
    return ia - ib;
}

static int cmp_cell_price(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;
    if (cities[ia].p < cities[ib].p) return 1;
    if (cities[ia].p > cities[ib].p) return -1;
    if (cities[ia].r > cities[ib].r) return 1;
    if (cities[ia].r < cities[ib].r) return -1;
    return ia - ib;
}

static int cmp_spatial_ids(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;

    if (spatial_mode == 0) {
        if (cities[ia].morton < cities[ib].morton) return -1;
        if (cities[ia].morton > cities[ib].morton) return 1;
    } else if (spatial_mode == 1) {
        double aa = cities[ia].ang + spatial_angle_offset;
        double ab = cities[ib].ang + spatial_angle_offset;
        if (aa >= TWO_PI) aa -= TWO_PI;
        if (ab >= TWO_PI) ab -= TWO_PI;
        if (aa < ab) return -1;
        if (aa > ab) return 1;
        if (cities[ia].r < cities[ib].r) return -1;
        if (cities[ia].r > cities[ib].r) return 1;
    } else if (spatial_mode == 2) {
        int ay = cities[ia].cell / GRID;
        int by = cities[ib].cell / GRID;
        int ax = cities[ia].cell % GRID;
        int bx = cities[ib].cell % GRID;
        if (ay != by) return ay - by;
        if (ay & 1) {
            if (ax != bx) return bx - ax;
        } else {
            if (ax != bx) return ax - bx;
        }
        if (cities[ia].p > cities[ib].p) return -1;
        if (cities[ia].p < cities[ib].p) return 1;
    } else if (spatial_mode == 4) {
        if (cities[ia].hilbert < cities[ib].hilbert) return -1;
        if (cities[ia].hilbert > cities[ib].hilbert) return 1;
        if (cities[ia].r < cities[ib].r) return -1;
        if (cities[ia].r > cities[ib].r) return 1;
    } else {
        if (cities[ia].r < cities[ib].r) return -1;
        if (cities[ia].r > cities[ib].r) return 1;
        double aa = cities[ia].ang + spatial_angle_offset;
        double ab = cities[ib].ang + spatial_angle_offset;
        if (aa >= TWO_PI) aa -= TWO_PI;
        if (ab >= TWO_PI) ab -= TWO_PI;
        if (aa < ab) return -1;
        if (aa > ab) return 1;
    }

    if (cities[ia].p > cities[ib].p) return -1;
    if (cities[ia].p < cities[ib].p) return 1;
    return ia - ib;
}

static void sort_order(int *order, int mode, double alpha) {
    cmp_mode = mode;
    cmp_alpha = alpha;
    for (int i = 0; i < n; ++i) order[i] = i;
    qsort(order, (size_t)n, sizeof(int), cmp_city_ids);
}

static void block_spatial_order(int *order, int *base, int mode) {
    memcpy(order, base, (size_t)n * sizeof(int));
    spatial_mode = mode;
    spatial_angle_offset = 0.0;
    for (int l = 0; l < n; l += block_size) {
        int len = block_size;
        if (l + len > n) len = n - l;
        if (len > 1) {
            qsort(order + l, (size_t)len, sizeof(int), cmp_spatial_ids);
        }
    }
}

static void block_spatial_order_offset(int *order, int *base, int mode, double offset) {
    memcpy(order, base, (size_t)n * sizeof(int));
    spatial_mode = mode;
    spatial_angle_offset = offset;
    for (int l = 0; l < n; l += block_size) {
        int len = block_size;
        if (l + len > n) len = n - l;
        if (len > 1) {
            qsort(order + l, (size_t)len, sizeof(int), cmp_spatial_ids);
        }
    }
    spatial_angle_offset = 0.0;
}

static void global_spatial_order(int *order, int mode, double offset) {
    for (int i = 0; i < n; ++i) order[i] = i;
    spatial_mode = mode;
    spatial_angle_offset = offset;
    if (n > 1) qsort(order, (size_t)n, sizeof(int), cmp_spatial_ids);
    spatial_angle_offset = 0.0;
}

static void prefix_spatial_order(int *order, int *base, int prefix, int mode, double offset) {
    memcpy(order, base, (size_t)n * sizeof(int));
    if (prefix < 0) prefix = 0;
    if (prefix > n) prefix = n;
    spatial_mode = mode;
    spatial_angle_offset = offset;
    if (prefix > 1) qsort(order, (size_t)prefix, sizeof(int), cmp_spatial_ids);
    spatial_angle_offset = 0.0;
}

static int probe_city_bucket(int id) {
    int ab = city_angle_bucket(id, probe_angle_bins, probe_offset);
    int rb = radius_bucket(cities[id].r, probe_radius_bins, probe_reverse_radius);
    return ab * probe_radius_bins + rb;
}

static int cmp_probe_buckets(const void *a, const void *b) {
    const ProbeBucket *pa = (const ProbeBucket *)a;
    const ProbeBucket *pb = (const ProbeBucket *)b;
    if (pa->key < pb->key) return 1;
    if (pa->key > pb->key) return -1;
    if (pa->tie < pb->tie) return 1;
    if (pa->tie > pb->tie) return -1;
    return pa->bucket - pb->bucket;
}

static int cmp_probe_bucket_city(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;
    int ba = probe_city_bucket(ia);
    int bb = probe_city_bucket(ib);
    int ra = probe_bucket_rank[ba];
    int rb = probe_bucket_rank[bb];
    if (ra != rb) return ra - rb;

    if (probe_inner_mode == 1) {
        if (cities[ia].hilbert < cities[ib].hilbert) return -1;
        if (cities[ia].hilbert > cities[ib].hilbert) return 1;
    } else if (probe_inner_mode == 2) {
        if (cities[ia].r < cities[ib].r) return -1;
        if (cities[ia].r > cities[ib].r) return 1;
    } else if (probe_inner_mode == 3) {
        double va = cities[ia].p / (1.0 + cities[ia].r);
        double vb = cities[ib].p / (1.0 + cities[ib].r);
        if (va > vb) return -1;
        if (va < vb) return 1;
    } else {
        if (cities[ia].p > cities[ib].p) return -1;
        if (cities[ia].p < cities[ib].p) return 1;
    }

    if (cities[ia].p > cities[ib].p) return -1;
    if (cities[ia].p < cities[ib].p) return 1;
    return ia - ib;
}

static void bucket_score_order(int *order, int angle_bins, int radius_bins,
                               int offset, int reverse_radius,
                               int score_mode, int inner_mode) {
    int total = angle_bins * radius_bins;
    int *cnt = (int *)calloc((size_t)total, sizeof(int));
    double *sum = (double *)calloc((size_t)total, sizeof(double));
    double *mx = (double *)malloc((size_t)total * sizeof(double));
    double *rsum = (double *)calloc((size_t)total, sizeof(double));
    ProbeBucket *buckets = (ProbeBucket *)malloc((size_t)total * sizeof(ProbeBucket));
    int *rank = (int *)malloc((size_t)total * sizeof(int));
    if (!cnt || !sum || !mx || !rsum || !buckets || !rank) exit(1);

    for (int i = 0; i < total; ++i) mx[i] = -INF;

    probe_angle_bins = angle_bins;
    probe_radius_bins = radius_bins;
    probe_offset = offset;
    probe_reverse_radius = reverse_radius;

    for (int i = 0; i < n; ++i) {
        int b = probe_city_bucket(i);
        cnt[b]++;
        sum[b] += cities[i].p;
        rsum[b] += cities[i].r;
        if (cities[i].p > mx[b]) mx[b] = cities[i].p;
    }

    for (int b = 0; b < total; ++b) {
        double avg = cnt[b] ? (sum[b] / (double)cnt[b]) : -INF;
        double ravg = cnt[b] ? (rsum[b] / (double)cnt[b]) : 0.0;
        buckets[b].bucket = b;
        if (score_mode == 1) {
            buckets[b].key = cnt[b] ? (sum[b] / sqrt((double)cnt[b])) : -INF;
            buckets[b].tie = avg;
        } else if (score_mode == 2) {
            buckets[b].key = mx[b];
            buckets[b].tie = avg;
        } else if (score_mode == 3) {
            buckets[b].key = avg - (0.15 + 0.05 * carry_cost) * ravg;
            buckets[b].tie = sum[b];
        } else {
            buckets[b].key = avg;
            buckets[b].tie = sum[b];
        }
    }

    qsort(buckets, (size_t)total, sizeof(ProbeBucket), cmp_probe_buckets);
    for (int i = 0; i < total; ++i) rank[buckets[i].bucket] = i;

    for (int i = 0; i < n; ++i) order[i] = i;
    probe_bucket_rank = rank;
    probe_inner_mode = inner_mode;
    qsort(order, (size_t)n, sizeof(int), cmp_probe_bucket_city);
    probe_bucket_rank = NULL;

    free(cnt);
    free(sum);
    free(mx);
    free(rsum);
    free(buckets);
    free(rank);
}

static void block_cell_order(int *order, int *base) {
    int total = GRID * GRID;
    int *cnt = (int *)calloc((size_t)total, sizeof(int));
    int *next = (int *)malloc((size_t)total * sizeof(int));
    if (!cnt || !next) exit(1);

    for (int l = 0; l < n; l += block_size) {
        int r = l + block_size;
        if (r > n) r = n;
        memset(cnt, 0, (size_t)total * sizeof(int));

        for (int i = l; i < r; ++i) {
            cnt[cities[base[i]].cell]++;
        }

        int pos = l;
        for (int gy = 0; gy < GRID; ++gy) {
            if (gy & 1) {
                for (int gx = GRID - 1; gx >= 0; --gx) {
                    int c = cell_id_xy(gx, gy);
                    next[c] = pos;
                    pos += cnt[c];
                }
            } else {
                for (int gx = 0; gx < GRID; ++gx) {
                    int c = cell_id_xy(gx, gy);
                    next[c] = pos;
                    pos += cnt[c];
                }
            }
        }

        for (int i = l; i < r; ++i) {
            int id = base[i];
            order[next[cities[id].cell]++] = id;
        }
    }

    free(cnt);
    free(next);
}

static void block_cell_column_order(int *order, int *base) {
    int total = GRID * GRID;
    int *cnt = (int *)calloc((size_t)total, sizeof(int));
    int *next = (int *)malloc((size_t)total * sizeof(int));
    if (!cnt || !next) exit(1);

    for (int l = 0; l < n; l += block_size) {
        int r = l + block_size;
        if (r > n) r = n;
        memset(cnt, 0, (size_t)total * sizeof(int));

        for (int i = l; i < r; ++i) {
            cnt[cities[base[i]].cell]++;
        }

        int pos = l;
        for (int gx = 0; gx < GRID; ++gx) {
            if (gx & 1) {
                for (int gy = GRID - 1; gy >= 0; --gy) {
                    int c = cell_id_xy(gx, gy);
                    next[c] = pos;
                    pos += cnt[c];
                }
            } else {
                for (int gy = 0; gy < GRID; ++gy) {
                    int c = cell_id_xy(gx, gy);
                    next[c] = pos;
                    pos += cnt[c];
                }
            }
        }

        for (int i = l; i < r; ++i) {
            int id = base[i];
            order[next[cities[id].cell]++] = id;
        }
    }

    free(cnt);
    free(next);
}

static int angle_bucket(double x, double y, int bins, int offset) {
    double a = atan2(y, x);
    if (a < 0.0) a += TWO_PI;
    int b = (int)(a * (double)bins / TWO_PI);
    if (b >= bins) b = bins - 1;
    b += offset;
    if (b >= bins) b -= bins;
    return b;
}

static int city_angle_bucket(int id, int bins, int offset) {
    if (bins == 96) {
        int b = cities[id].angle96 + offset;
        while (b >= 96) b -= 96;
        while (b < 0) b += 96;
        return b;
    }
    return angle_bucket(cities[id].x, cities[id].y, bins, offset);
}

static int radius_bucket(double r, int bins, int reverse) {
    int b = (int)(r * (double)bins / 1415.0);
    if (b < 0) b = 0;
    if (b >= bins) b = bins - 1;
    return reverse ? (bins - 1 - b) : b;
}

static void block_polar_bucket_order(int *order, int *base,
                                     int angle_bins, int radius_bins,
                                     int offset, int reverse_radius) {
    int total = angle_bins * radius_bins;
    int *cnt = (int *)calloc((size_t)total, sizeof(int));
    int *next = (int *)malloc((size_t)total * sizeof(int));
    if (!cnt || !next) exit(1);

    for (int l = 0; l < n; l += block_size) {
        int r = l + block_size;
        if (r > n) r = n;
        memset(cnt, 0, (size_t)total * sizeof(int));

        for (int i = l; i < r; ++i) {
            int id = base[i];
            int ab = city_angle_bucket(id, angle_bins, offset);
            int rb = radius_bucket(cities[id].r, radius_bins, reverse_radius);
            cnt[ab * radius_bins + rb]++;
        }

        int pos = l;
        for (int ab = 0; ab < angle_bins; ++ab) {
            if (ab & 1) {
                for (int rb = radius_bins - 1; rb >= 0; --rb) {
                    int b = ab * radius_bins + rb;
                    next[b] = pos;
                    pos += cnt[b];
                }
            } else {
                for (int rb = 0; rb < radius_bins; ++rb) {
                    int b = ab * radius_bins + rb;
                    next[b] = pos;
                    pos += cnt[b];
                }
            }
        }

        for (int i = l; i < r; ++i) {
            int id = base[i];
            int ab = city_angle_bucket(id, angle_bins, offset);
            int rb = radius_bucket(cities[id].r, radius_bins, reverse_radius);
            int b = ab * radius_bins + rb;
            order[next[b]++] = id;
        }
    }

    free(cnt);
    free(next);
}

static int center_bucket_index(int id, int rings) {
    double rr = cities[id].r;
    int b = (int)(rr * (double)rings / 1415.0);
    if (b < 0) b = 0;
    if (b >= rings) b = rings - 1;
    return b;
}

static void block_radial_cell_order(int *order, int *base, int rings) {
    int total = rings * GRID;
    int *cnt = (int *)calloc((size_t)total, sizeof(int));
    int *next = (int *)malloc((size_t)total * sizeof(int));
    if (!cnt || !next) exit(1);

    for (int l = 0; l < n; l += block_size) {
        int r = l + block_size;
        if (r > n) r = n;
        memset(cnt, 0, (size_t)total * sizeof(int));

        for (int i = l; i < r; ++i) {
            int id = base[i];
            int rb = center_bucket_index(id, rings);
            int cb = cities[id].cell % GRID;
            cnt[rb * GRID + cb]++;
        }

        int pos = l;
        for (int rb = 0; rb < rings; ++rb) {
            if (rb & 1) {
                for (int cb = GRID - 1; cb >= 0; --cb) {
                    int b = rb * GRID + cb;
                    next[b] = pos;
                    pos += cnt[b];
                }
            } else {
                for (int cb = 0; cb < GRID; ++cb) {
                    int b = rb * GRID + cb;
                    next[b] = pos;
                    pos += cnt[b];
                }
            }
        }

        for (int i = l; i < r; ++i) {
            int id = base[i];
            int rb = center_bucket_index(id, rings);
            int cb = cities[id].cell % GRID;
            int b = rb * GRID + cb;
            order[next[b]++] = id;
        }
    }

    free(cnt);
    free(next);
}

static int block_local_pick(double lx, double ly,
                            unsigned int *active_marks,
                            unsigned int *taken_marks,
                            unsigned int active_tag,
                            unsigned int taken_tag,
                            int rings, int limit,
                            double price_weight, double dist_weight) {
    int cx = coord_cell(lx);
    int cy = coord_cell(ly);
    int best = -1;
    double best_score = -INF;

    for (int dy = -rings; dy <= rings; ++dy) {
        int gy = cy + dy;
        if (gy < 0 || gy >= GRID) continue;
        for (int dx = -rings; dx <= rings; ++dx) {
            int gx = cx + dx;
            if (gx < 0 || gx >= GRID) continue;

            Cell *cell = &cells[cell_id_xy(gx, gy)];
            int seen = 0;
            for (int q = 0; q < cell->count && seen < limit; ++q) {
                int id = cell->ids[q];
                if (active_marks[id] != active_tag || taken_marks[id] == taken_tag) continue;
                seen++;

                double d = dist2d(lx, ly, cities[id].x, cities[id].y);
                double score = price_weight * cities[id].p - dist_weight * d;
                if (score > best_score) {
                    best_score = score;
                    best = id;
                }
            }
        }
    }

    return best;
}

static unsigned int prepare_local_cell_index(int *src, int l, int r,
                                             unsigned int *active_marks,
                                             unsigned int active_tag) {
    unsigned int cell_tag = solver_next_local_cell_tag();
    int touched_count = 0;
    int total = 0;

    for (int i = l; i < r; ++i) {
        int cell = cities[src[i]].cell;
        if (solver_local_cell_marks[cell] != cell_tag) {
            solver_local_cell_marks[cell] = cell_tag;
            solver_local_cell_counts[cell] = 0;
            solver_local_cell_touched[touched_count++] = cell;
        }
        solver_local_cell_counts[cell]++;
    }

    for (int i = 0; i < touched_count; ++i) {
        int cell = solver_local_cell_touched[i];
        solver_local_cell_offsets[cell] = total;
        total += solver_local_cell_counts[cell];
        solver_local_cell_counts[cell] = 0;
    }

    for (int i = 0; i < touched_count; ++i) {
        int cell = solver_local_cell_touched[i];
        Cell *bucket = &cells[cell];
        int off = solver_local_cell_offsets[cell];
        int cnt = 0;
        for (int q = 0; q < bucket->count; ++q) {
            int id = bucket->ids[q];
            if (active_marks[id] == active_tag) {
                solver_local_cell_ids[off + cnt++] = id;
            }
        }
        solver_local_cell_counts[cell] = cnt;
    }

    return cell_tag;
}

static int block_local_pick_compact(double lx, double ly,
                                    unsigned int *taken_marks,
                                    unsigned int taken_tag,
                                    unsigned int cell_tag,
                                    int rings, int limit,
                                    double price_weight, double dist_weight) {
    int cx = coord_cell(lx);
    int cy = coord_cell(ly);
    int best = -1;
    double best_score = -INF;

    for (int dy = -rings; dy <= rings; ++dy) {
        int gy = cy + dy;
        if (gy < 0 || gy >= GRID) continue;
        for (int dx = -rings; dx <= rings; ++dx) {
            int gx = cx + dx;
            if (gx < 0 || gx >= GRID) continue;

            int cell = cell_id_xy(gx, gy);
            int seen = 0;
            if (solver_local_cell_marks[cell] != cell_tag) continue;

            {
                int off = solver_local_cell_offsets[cell];
                int cnt = solver_local_cell_counts[cell];
                for (int q = 0; q < cnt && seen < limit; ++q) {
                    int id = solver_local_cell_ids[off + q];
                    if (taken_marks[id] == taken_tag) continue;
                    seen++;

                    double d = dist2d(lx, ly, cities[id].x, cities[id].y);
                    double score = price_weight * cities[id].p - dist_weight * d;
                    if (score > best_score) {
                        best_score = score;
                        best = id;
                    }
                }
            }
        }
    }

    return best;
}

static int block_nearest_order(int *order, int *base,
                               int rings, int limit,
                               double price_weight, double dist_weight) {
    unsigned int *active;
    unsigned int *taken;
    int any = 0;
    ensure_solver_workspace();
    active = solver_active_marks;
    taken = solver_taken_marks;

    for (int l = 0; l < n; l += block_size) {
        int r = l + block_size;
        if (r > n) r = n;
        unsigned int active_tag, taken_tag;
        solver_next_mark_pair(&active_tag, &taken_tag);

        for (int i = l; i < r; ++i) {
            active[base[i]] = active_tag;
        }

        unsigned int cell_tag = prepare_local_cell_index(base, l, r, active, active_tag);

        double lx = 0.0;
        double ly = 0.0;
        int scan = l;
        for (int pos = l; pos < r; ++pos) {
            int chosen = block_local_pick_compact(lx, ly, taken, taken_tag,
                                                  cell_tag, rings, limit,
                                                  price_weight, dist_weight);
            if (chosen < 0) {
                while (scan < r && taken[base[scan]] == taken_tag) scan++;
                if (scan < r) chosen = base[scan++];
            }
            if (chosen < 0) chosen = base[pos];

            order[pos] = chosen;
            any |= (chosen != base[pos]);
            taken[chosen] = taken_tag;
            lx = cities[chosen].x;
            ly = cities[chosen].y;
        }
    }
    return any;
}

static void build_grid(void) {
    int total = GRID * GRID;
    cells = (Cell *)calloc((size_t)total, sizeof(Cell));
    if (!cells) exit(1);

    for (int i = 0; i < n; ++i) {
        cities[i].cell = city_cell(cities[i].x, cities[i].y);
        cells[cities[i].cell].count++;
    }

    for (int i = 0; i < total; ++i) {
        if (cells[i].count > 0) {
            cells[i].ids = (int *)malloc((size_t)cells[i].count * sizeof(int));
            if (!cells[i].ids) exit(1);
        }
    }

    for (int i = 0; i < n; ++i) {
        Cell *c = &cells[cities[i].cell];
        c->ids[c->fill++] = i;
    }

    for (int i = 0; i < total; ++i) {
        if (cells[i].count > 1) {
            qsort(cells[i].ids, (size_t)cells[i].count, sizeof(int), cmp_cell_price);
        }
    }
}

static void reset_grid_cursors(void) {
    for (int i = 0; i < GRID * GRID; ++i) cells[i].cursor = 0;
}

static void reset_used(void) {
    for (int i = 0; i < n; ++i) cities[i].used = 0;
}

static unsigned int rng_next(unsigned int *state) {
    unsigned int x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *state = x;
    return x;
}

static int next_global_city(int *base, int *ptr) {
    while (*ptr < n && cities[base[*ptr]].used) (*ptr)++;
    if (*ptr >= n) return -1;
    return base[*ptr];
}

static int local_best(double lx, double ly, int pos, int rings, int limit,
                      double lambda, int random_checks, unsigned int *seed,
                      double *score_out) {
    int cx = coord_cell(lx);
    int cy = coord_cell(ly);
    int level = visit_level(pos);

    int best = -1;
    double best_score = -INF;

    for (int dy = -rings; dy <= rings; ++dy) {
        int gy = cy + dy;
        if (gy < 0 || gy >= GRID) continue;
        for (int dx = -rings; dx <= rings; ++dx) {
            int gx = cx + dx;
            if (gx < 0 || gx >= GRID) continue;
            Cell *cell = &cells[cell_id_xy(gx, gy)];

            int p = cell->cursor;
            while (p < cell->count && cities[cell->ids[p]].used) p++;
            cell->cursor = p;

            int seen = 0;
            for (int q = p; q < cell->count && seen < limit; ++q) {
                int id = cell->ids[q];
                if (cities[id].used) continue;
                seen++;
                double d = dist2d(lx, ly, cities[id].x, cities[id].y);
                double score = factors[level] * cities[id].p - lambda * d
                             - 0.10 * carry_cost * cities[id].r;
                if (score > best_score) {
                    best_score = score;
                    best = id;
                }
            }
        }
    }

    for (int i = 0; i < random_checks; ++i) {
        int id = (int)(rng_next(seed) % (unsigned int)n);
        if (cities[id].used) continue;
        double d = dist2d(lx, ly, cities[id].x, cities[id].y);
        double score = factors[level] * cities[id].p - lambda * d
                     - 0.20 * carry_cost * cities[id].r;
        if (score > best_score) {
            best_score = score;
            best = id;
        }
    }

    *score_out = best_score;
    return best;
}

static void build_greedy_order(int *order, int *base, int rings, int limit,
                               double lambda, double jump_alpha,
                               int random_checks, unsigned int seed) {
    reset_used();
    reset_grid_cursors();

    int base_ptr = 0;
    double lx = 0.0, ly = 0.0;

    for (int pos = 0; pos < n; ++pos) {
        int level = visit_level(pos);

        int global = next_global_city(base, &base_ptr);
        double global_score = -INF;
        if (global >= 0) {
            global_score = factors[level] * cities[global].p
                         - jump_alpha * cities[global].r;
        }

        double loc_score = -INF;
        int loc = local_best(lx, ly, pos, rings, limit, lambda,
                             random_checks, &seed, &loc_score);

        int chosen = global;
        if (loc >= 0 && (global < 0 || loc_score > global_score)) {
            chosen = loc;
        }
        if (chosen < 0) {
            for (int i = 0; i < n; ++i) {
                if (!cities[i].used) {
                    chosen = i;
                    break;
                }
            }
        }

        order[pos] = chosen;
        cities[chosen].used = 1;
        lx = cities[chosen].x;
        ly = cities[chosen].y;
    }
}

static void build_seed_cluster_order(int *order, int *base, int cluster_len,
                                     int rings, int limit, double lambda,
                                     double jump_alpha, double local_bias,
                                     int random_checks, unsigned int seed) {
    reset_used();
    reset_grid_cursors();

    int base_ptr = 0;
    int pos = 0;
    while (pos < n) {
        int chosen = next_global_city(base, &base_ptr);
        if (chosen < 0) {
            for (int i = 0; i < n; ++i) {
                if (!cities[i].used) {
                    chosen = i;
                    break;
                }
            }
        }
        if (chosen < 0) break;

        order[pos++] = chosen;
        cities[chosen].used = 1;

        double lx = cities[chosen].x;
        double ly = cities[chosen].y;
        for (int k = 1; k < cluster_len && pos < n; ++k) {
            int level = visit_level(pos);
            int global = next_global_city(base, &base_ptr);
            double global_score = -INF;
            if (global >= 0) {
                global_score = factors[level] * cities[global].p
                             - jump_alpha * cities[global].r;
            }

            double loc_score = -INF;
            int loc = local_best(lx, ly, pos, rings, limit, lambda,
                                 random_checks, &seed, &loc_score);
            if (loc < 0 || (global >= 0 && loc_score + local_bias < global_score)) {
                break;
            }

            order[pos++] = loc;
            cities[loc].used = 1;
            lx = cities[loc].x;
            ly = cities[loc].y;
        }
    }

    for (int i = 0; pos < n && i < n; ++i) {
        if (!cities[i].used) {
            order[pos++] = i;
            cities[i].used = 1;
        }
    }
}

#define KD_LEAF_SIZE 16
#define KD_QUERY_STACK_CAP 256

static void kd_release_tree(void) {
    free(kd_nodes);
    free(kd_city_node);
    free(kd_ids);
    kd_nodes = NULL;
    kd_city_node = NULL;
    kd_ids = NULL;
    kd_root = -1;
    kd_count = 0;
    kd_subset_n = 0;
}

static void kd_reset_perf_stats(void) {
    memset(&kd_perf_stats, 0, sizeof(kd_perf_stats));
}

static inline int kd_cmp_ids_axis(int ia, int ib, int axis) {
    double va = axis ? cities[ia].y : cities[ia].x;
    double vb = axis ? cities[ib].y : cities[ib].x;
    if (va < vb) return -1;
    if (va > vb) return 1;
    va = axis ? cities[ia].x : cities[ia].y;
    vb = axis ? cities[ib].x : cities[ib].y;
    if (va < vb) return -1;
    if (va > vb) return 1;
    return ia - ib;
}

static inline void kd_swap_int(int *a, int *b) {
    int t = *a;
    *a = *b;
    *b = t;
}

static void kd_insertion_sort(int *ids, int l, int r, int axis) {
    for (int i = l + 1; i < r; ++i) {
        int v = ids[i];
        int j = i;
        while (j > l && kd_cmp_ids_axis(v, ids[j - 1], axis) < 0) {
            ids[j] = ids[j - 1];
            --j;
        }
        ids[j] = v;
    }
}

static inline int kd_median3_id(int a, int b, int c, int axis) {
    if (kd_cmp_ids_axis(a, b, axis) > 0) kd_swap_int(&a, &b);
    if (kd_cmp_ids_axis(b, c, axis) > 0) kd_swap_int(&b, &c);
    if (kd_cmp_ids_axis(a, b, axis) > 0) kd_swap_int(&a, &b);
    return b;
}

static void kd_nth_element(int *ids, int l, int r, int nth, int axis) {
    while (r - l > 32) {
        int mid = l + ((r - l) >> 1);
        int pivot = kd_median3_id(ids[l], ids[mid], ids[r - 1], axis);
        int i = l;
        int j = r - 1;

        for (;;) {
            while (kd_cmp_ids_axis(ids[i], pivot, axis) < 0) ++i;
            while (kd_cmp_ids_axis(ids[j], pivot, axis) > 0) --j;
            if (i >= j) break;
            kd_swap_int(&ids[i], &ids[j]);
            ++i;
            --j;
        }

        if (nth <= j) {
            r = j + 1;
        } else {
            l = j + 1;
        }
    }
    kd_insertion_sort(ids, l, r, axis);
}

static inline double kd_box_dist2_node(const KDNode *node, double x, double y) {
    double dx = 0.0;
    double dy = 0.0;
    if (x < node->minx) dx = node->minx - x;
    else if (x > node->maxx) dx = x - node->maxx;
    if (y < node->miny) dy = node->miny - y;
    else if (y > node->maxy) dy = y - node->maxy;
    return dx * dx + dy * dy;
}

static int kd_build_rec(int *ids, int l, int r, int parent) {
    if (l >= r) return -1;

    int node = kd_count++;
    KDNode *cur = &kd_nodes[node];
    cur->parent = parent;
    cur->left = -1;
    cur->right = -1;
    cur->begin = l;
    cur->end = r;
    cur->full_count = r - l;
    cur->active_count = cur->full_count;

    {
        int id0 = ids[l];
        cur->minx = cur->maxx = cities[id0].x;
        cur->miny = cur->maxy = cities[id0].y;
        cur->min_r = cur->max_r = cities[id0].r;
        cur->max_p = cities[id0].p;
        for (int i = l + 1; i < r; ++i) {
            int id = ids[i];
            if (cities[id].x < cur->minx) cur->minx = cities[id].x;
            if (cities[id].x > cur->maxx) cur->maxx = cities[id].x;
            if (cities[id].y < cur->miny) cur->miny = cities[id].y;
            if (cities[id].y > cur->maxy) cur->maxy = cities[id].y;
            if (cities[id].r < cur->min_r) cur->min_r = cities[id].r;
            if (cities[id].r > cur->max_r) cur->max_r = cities[id].r;
            if (cities[id].p > cur->max_p) cur->max_p = cities[id].p;
        }
    }

    if (r - l <= KD_LEAF_SIZE) {
        /* Leaf nodes own a contiguous slice [begin, end) in kd_ids. */
        for (int i = l; i < r; ++i) kd_city_node[ids[i]] = node;
        return node;
    }

    {
        double spread_x = cur->maxx - cur->minx;
        double spread_y = cur->maxy - cur->miny;
        int axis = (spread_x >= spread_y) ? 0 : 1;
        int mid = l + ((r - l) >> 1);
        kd_nth_element(ids, l, r, mid, axis);
        cur->begin = -1;
        cur->end = -1;
        cur->left = kd_build_rec(ids, l, mid, node);
        cur->right = kd_build_rec(ids, mid, r, node);
    }

    return node;
}

static void ensure_kd_tree(void) {
    if (kd_nodes) return;

    kd_subset_n = n;
    if (n > 45000) kd_subset_n = 20000;
    if (kd_subset_n < 10000) kd_subset_n = n;

    kd_nodes = (KDNode *)malloc((size_t)(2 * kd_subset_n + 8) * sizeof(KDNode));
    kd_city_node = (int *)malloc((size_t)n * sizeof(int));
    kd_ids = (int *)malloc((size_t)kd_subset_n * sizeof(int));
    if (!kd_nodes || !kd_city_node || !kd_ids) exit(1);

    for (int i = 0; i < n; ++i) kd_city_node[i] = -1;

    if (kd_subset_n < n) {
        int *all = (int *)malloc((size_t)n * sizeof(int));
        if (!all) exit(1);
        cmp_mode = 0;
        cmp_alpha = 1.0 + carry_cost;
        for (int i = 0; i < n; ++i) all[i] = i;
        qsort(all, (size_t)n, sizeof(int), cmp_city_ids);
        for (int i = 0; i < kd_subset_n; ++i) kd_ids[i] = all[i];
        free(all);
    } else {
        for (int i = 0; i < n; ++i) kd_ids[i] = i;
    }

    kd_count = 0;
    kd_root = kd_build_rec(kd_ids, 0, kd_subset_n, -1);
}

static void kd_reset_active(void) {
    ensure_kd_tree();
    for (int i = 0; i < kd_count; ++i) kd_nodes[i].active_count = kd_nodes[i].full_count;
}

static void kd_deactivate_city(int id) {
    int node = kd_city_node[id];
    while (node >= 0) {
        kd_nodes[node].active_count--;
        node = kd_nodes[node].parent;
    }
}

static int kd_best_city(double x, double y, int pos, double lambda,
                        double radial_penalty, double initial_score,
                        double *score_out) {
    int best = -1;
    double best_score = initial_score;
    double factor = factors[visit_level(pos)];
    int stack[KD_QUERY_STACK_CAP];
    int top = 0;

    ensure_kd_tree();
    if (kd_root < 0) {
        *score_out = best_score;
        return -1;
    }

    stack[top++] = kd_root;
    while (top > 0) {
        int node = stack[--top];
        KDNode *cur = &kd_nodes[node];
        if (kd_perf_enabled) ++kd_perf_stats.visited_nodes;

        if (cur->active_count <= 0) {
            if (kd_perf_enabled) ++kd_perf_stats.prune_count;
            continue;
        }

        {
            /*
             * Upper bound over a subtree:
             * factor * max_p - lambda * min_dist(q, bbox) - radial_penalty * best_radial_term
             * is valid for lambda >= 0 and the solver's non-negative penalty regime.
             */
            double radial_r = radial_penalty >= 0.0 ? cur->min_r : cur->max_r;
            double bound = factor * cur->max_p - radial_penalty * radial_r;
            if (bound <= best_score + EPS) {
                if (kd_perf_enabled) ++kd_perf_stats.prune_count;
                continue;
            }
            if (lambda > EPS) {
                double need = (bound - best_score) / lambda;
                double dist2_lb = kd_box_dist2_node(cur, x, y);
                if (dist2_lb + EPS >= need * need) {
                    if (kd_perf_enabled) ++kd_perf_stats.prune_count;
                    continue;
                }
            }
        }

        if (cur->left < 0 && cur->right < 0) {
            for (int i = cur->begin; i < cur->end; ++i) {
                int id = kd_ids[i];
                double point_base;
                double dx, dy, dist2;
                if (kd_perf_enabled) ++kd_perf_stats.checked_points;
                if (cities[id].used) continue;

                point_base = factor * cities[id].p - radial_penalty * cities[id].r;
                if (lambda >= 0.0 && point_base <= best_score + EPS) continue;

                dx = x - cities[id].x;
                dy = y - cities[id].y;
                dist2 = dx * dx + dy * dy;

                if (lambda > EPS) {
                    /* Avoid sqrt unless the point can still beat best_score. */
                    double need = (point_base - best_score) / lambda;
                    if (need <= 0.0 || dist2 + EPS >= need * need) continue;
                    if (kd_perf_enabled) ++kd_perf_stats.sqrt_evaluations;
                    {
                        double score = point_base - lambda * sqrt(dist2);
                        if (score > best_score + EPS) {
                            best_score = score;
                            best = id;
                        }
                    }
                } else if (lambda >= -EPS) {
                    if (point_base > best_score + EPS) {
                        best_score = point_base;
                        best = id;
                    }
                } else {
                    if (kd_perf_enabled) ++kd_perf_stats.sqrt_evaluations;
                    {
                        double score = point_base - lambda * sqrt(dist2);
                        if (score > best_score + EPS) {
                            best_score = score;
                            best = id;
                        }
                    }
                }
            }
            continue;
        }

        {
            int left = cur->left;
            int right = cur->right;
            double dl = left >= 0 ? kd_box_dist2_node(&kd_nodes[left], x, y) : INF;
            double dr = right >= 0 ? kd_box_dist2_node(&kd_nodes[right], x, y) : INF;
            if (dl < dr) {
                if (right >= 0) stack[top++] = right;
                if (left >= 0) stack[top++] = left;
            } else {
                if (left >= 0) stack[top++] = left;
                if (right >= 0) stack[top++] = right;
            }
        }
    }

    *score_out = best_score;
    return best;
}

static void build_kd_greedy_order(int *order, int *base,
                                  double lambda, double jump_alpha,
                                  double radial_penalty) {
    reset_used();
    kd_reset_active();

    {
        int kd_prefix = n;
        int base_ptr = 0;
        double lx = 0.0;
        double ly = 0.0;
        int pos = 0;
        if (n > 45000 && kd_prefix > 1500) kd_prefix = 1500;

        for (; pos < kd_prefix; ++pos) {
            int level = visit_level(pos);
            int global = next_global_city(base, &base_ptr);
            double global_score = -INF;
            if (global >= 0) {
                global_score = factors[level] * cities[global].p
                             - jump_alpha * cities[global].r;
            }

            {
                double loc_score = -INF;
                int loc = kd_best_city(lx, ly, pos, lambda, radial_penalty,
                                       global_score, &loc_score);
                int chosen = global;
                if (loc >= 0 && (global < 0 || loc_score > global_score)) {
                    chosen = loc;
                }
                if (chosen < 0) {
                    for (int i = 0; i < n; ++i) {
                        if (!cities[i].used) {
                            chosen = i;
                            break;
                        }
                    }
                }

                order[pos] = chosen;
                cities[chosen].used = 1;
                kd_deactivate_city(chosen);
                lx = cities[chosen].x;
                ly = cities[chosen].y;
            }
        }

        for (; pos < n; ++pos) {
            int chosen = next_global_city(base, &base_ptr);
            if (chosen < 0) {
                for (int i = 0; i < n; ++i) {
                    if (!cities[i].used) {
                        chosen = i;
                        break;
                    }
                }
            }

            order[pos] = chosen;
            cities[chosen].used = 1;
        }
    }
}

static inline double line_value(Line ln, double x) {
    return ln.m * x + ln.b;
}

static Line make_line(int *order, int l) {
    int id = order[l - 1];
    double r = cities[id].r;
    Line ln;
    ln.m = carry_cost * (r - pref_s[l]);
    ln.b = dp[l - 1] + r - pref_s[l] + carry_cost * pref_t[l]
         - carry_cost * (double)l * r;
    ln.id = l;
    ln.gen = lichao_epoch;
    return ln;
}

static void lichao_clear(void) {
    ++lichao_epoch;
    if (lichao_epoch == 0u) {
        memset(tree, 0, (size_t)(4 * (tree_xmax + 2)) * sizeof(Line));
        lichao_epoch = 1u;
    }
}

static void lichao_insert_rec(int node, int l, int r, Line nw) {
    if (tree[node].gen != lichao_epoch) {
        tree[node] = nw;
        return;
    }

    int mid = (l + r) >> 1;
    Line lo = tree[node];
    int left = line_value(nw, (double)l) < line_value(lo, (double)l);
    int middle = line_value(nw, (double)mid) < line_value(lo, (double)mid);

    if (middle) {
        tree[node] = nw;
        nw = lo;
    }

    if (l == r) return;
    if (left != middle) {
        lichao_insert_rec(node << 1, l, mid, nw);
    } else {
        lichao_insert_rec(node << 1 | 1, mid + 1, r, nw);
    }
}

static void lichao_insert(Line ln) {
    lichao_insert_rec(1, 1, tree_xmax, ln);
}

static Query query_best(Query a, Query b) {
    if (b.value + EPS < a.value) return b;
    return a;
}

static Query lichao_query_rec(int node, int l, int r, int x) {
    Query ans;
    ans.value = INF;
    ans.id = -1;

    if (tree[node].gen == lichao_epoch) {
        ans.value = line_value(tree[node], (double)x);
        ans.id = tree[node].id;
    }
    if (l == r) return ans;

    int mid = (l + r) >> 1;
    Query sub;
    if (x <= mid) {
        sub = lichao_query_rec(node << 1, l, mid, x);
    } else {
        sub = lichao_query_rec(node << 1 | 1, mid + 1, r, x);
    }
    return query_best(ans, sub);
}

static Query lichao_query(int x) {
    return lichao_query_rec(1, 1, tree_xmax, x);
}

static Eval evaluate_order(int *order, int keep_parents) {
    Eval best;
    best.profit = 0.0;
    best.visits = 0;
    best.final_l = 0;

    pref_s[0] = pref_s[1] = 0.0;
    pref_t[0] = pref_t[1] = 0.0;
    for (int i = 2; i <= n; ++i) {
        City *a = &cities[order[i - 2]];
        City *b = &cities[order[i - 1]];
        double e = dist2d(a->x, a->y, b->x, b->y);
        pref_s[i] = pref_s[i - 1] + e;
        pref_t[i] = pref_t[i - 1] + (double)i * e;
    }

    lichao_clear();
    dp[0] = 0.0;
    lichao_insert(make_line(order, 1));

    double revenue = 0.0;
    for (int r = 1; r <= n; ++r) {
        int id = order[r - 1];
        int level = visit_level(r - 1);
        revenue += factors[level] * cities[id].p;

        Query q = lichao_query(r + 1);
        double common = pref_s[r] + carry_cost * ((double)(r + 1) * pref_s[r] - pref_t[r]);

        dp[r] = common + cities[id].r + q.value;
        if (keep_parents) parent_ret[r] = q.id;

        double final_cost = common + q.value;
        double profit = revenue - final_cost;
        if (profit > best.profit + EPS) {
            best.profit = profit;
            best.visits = r;
            best.final_l = q.id;
        }

        if (r < n) {
            lichao_insert(make_line(order, r + 1));
        }
    }

    return best;
}

static void reconstruct_starts(int *order, Eval best, unsigned char *starts) {
    (void)order;
    memset(starts, 0, (size_t)n * sizeof(unsigned char));
    if (best.visits <= 0) return;

    int l = best.final_l;
    int r = best.visits;
    if (l < 1) return;
    starts[l - 1] = 1;
    r = l - 1;

    while (r > 0) {
        l = parent_ret[r];
        if (l < 1 || l > r) break;
        starts[l - 1] = 1;
        r = l - 1;
    }

    for (int i = 0; i < best.visits; ++i) {
        if (order[i] == hq_city) starts[i] = 1;
    }
}

static void consider_candidate(int *order, int *best_order, Eval *best_eval) {
    Eval cur = evaluate_order(order, 0);
    if (cur.profit > best_eval->profit + EPS) {
        *best_eval = cur;
        memcpy(best_order, order, (size_t)n * sizeof(int));
        solver_refresh_best_cache(best_order);
    }
}

static inline void consider_candidate_if_changed(int changed,
                                                 int *order,
                                                 int *best_order,
                                                 Eval *best_eval) {
    if (changed) consider_candidate(order, best_order, best_eval);
}

static Eval solver_get_trip_eval(int *src, unsigned char **starts_out) {
    Eval ev;
    ensure_solver_workspace();
    if (solver_best_cache_valid && solver_best_cache_order_ptr == src) {
        *starts_out = solver_best_starts;
        return solver_best_cache_eval;
    }
    ev = evaluate_order(src, 1);
    reconstruct_starts(src, ev, solver_starts);
    *starts_out = solver_starts;
    return ev;
}

static int trip_nearest_reorder(int *src, int *dst, double price_weight, double dist_weight) {
    Eval ev;
    unsigned char *starts;
    unsigned int *active;
    unsigned int *taken;
    int any = 0;
    ensure_solver_workspace();
    ev = solver_get_trip_eval(src, &starts);
    active = solver_active_marks;
    taken = solver_taken_marks;
    memcpy(dst, src, (size_t)n * sizeof(int));

    int pos = 0;
    while (pos < ev.visits) {
        int end = pos + 1;
        while (end < ev.visits && !starts[end]) end++;
        unsigned int active_tag, taken_tag;
        solver_next_mark_pair(&active_tag, &taken_tag);

        for (int i = pos; i < end; ++i) {
            active[src[i]] = active_tag;
        }

        int use_compact = (end - pos >= 128);
        unsigned int cell_tag = 0u;
        if (use_compact) {
            cell_tag = prepare_local_cell_index(src, pos, end, active, active_tag);
        }

        double lx = 0.0;
        double ly = 0.0;
        int scan = pos;
        for (int i = pos; i < end; ++i) {
            int chosen;
            if (use_compact) {
                chosen = block_local_pick_compact(lx, ly, taken, taken_tag,
                                                  cell_tag, 12, 16,
                                                  price_weight, dist_weight);
            } else {
                chosen = block_local_pick(lx, ly, active, taken,
                                          active_tag, taken_tag,
                                          12, 16, price_weight, dist_weight);
            }
            if (chosen < 0) {
                while (scan < end && taken[src[scan]] == taken_tag) scan++;
                if (scan < end) chosen = src[scan++];
            }
            if (chosen < 0) chosen = src[i];

            dst[i] = chosen;
            any |= (chosen != src[i]);
            taken[chosen] = taken_tag;
            lx = cities[chosen].x;
            ly = cities[chosen].y;
        }
        pos = end;
    }

    for (int i = ev.visits; i < n; ++i) dst[i] = src[i];
    return any;
}

static double trip_range_score(int *order, int l, int r, int returning) {
    double score = 0.0;
    double lx = 0.0;
    double ly = 0.0;

    for (int i = l; i < r; ++i) {
        int id = order[i];
        int carrying = r - i;
        int level = visit_level(i);

        double d = dist2d(lx, ly, cities[id].x, cities[id].y);
        score += factors[level] * cities[id].p
               - d * (1.0 + carry_cost * (double)carrying);
        lx = cities[id].x;
        ly = cities[id].y;
    }

    if (returning && r > l) {
        score -= cities[order[r - 1]].r;
    }
    return score;
}

static void reverse_range(int *a, int l, int r);
static double trip_window_score(int *order, int trip_l, int trip_r,
                                int l, int r, int returning);

static void relocate_item(int *order, int l, int r, int from, int to) {
    int id = order[from];
    if (from < to) {
        for (int i = from; i < to - 1; ++i) order[i] = order[i + 1];
        order[to - 1] = id;
    } else if (from > to) {
        for (int i = from; i > to; --i) order[i] = order[i - 1];
        order[to] = id;
    }
    (void)l;
    (void)r;
}

static void undo_relocate_item(int *order, int l, int r, int from, int to) {
    if (from < to) {
        relocate_item(order, l, r, to - 1, from);
    } else if (from > to) {
        relocate_item(order, l, r, to, from + 1);
    }
}

static int improve_trip_range(int *order, int l, int r, int returning) {
    int len = r - l;
    int any = 0;
    if (len <= 1) return 0;

    int full_limit = 70;
    int window_limit = 90;
    if (len > window_limit) return 0;

    int passes = (len <= full_limit)
        ? (deep_trip_polish ? 40 : 20)
        : (deep_trip_polish ? 10 : 6);
    double current = trip_range_score(order, l, r, returning);

    for (int pass = 0; pass < passes; ++pass) {
        int improved = 0;

        for (int i = l; i < r && !improved; ++i) {
            for (int j = i + 1; j < r && !improved; ++j) {
                double old_seg = trip_window_score(order, l, r, i, j + 1, returning);
                int t = order[i];
                order[i] = order[j];
                order[j] = t;
                double new_seg = trip_window_score(order, l, r, i, j + 1, returning);
                double cand = current - old_seg + new_seg;
                if (cand > current + EPS) {
                    current = cand;
                    improved = 1;
                    any = 1;
                } else {
                    t = order[i];
                    order[i] = order[j];
                    order[j] = t;
                }
            }
        }

        for (int i = l; i < r && !improved; ++i) {
            for (int j = i + 2; j <= r && !improved; ++j) {
                double old_seg = trip_window_score(order, l, r, i, j, returning);
                reverse_range(order, i, j);
                double new_seg = trip_window_score(order, l, r, i, j, returning);
                double cand = current - old_seg + new_seg;
                if (cand > current + EPS) {
                    current = cand;
                    improved = 1;
                    any = 1;
                } else {
                    reverse_range(order, i, j);
                }
            }
        }

        for (int i = l; i < r && !improved; ++i) {
            for (int j = l; j <= r && !improved; ++j) {
                int seg_l, seg_r;
                if (j == i || j == i + 1) continue;
                if (i < j) {
                    seg_l = i;
                    seg_r = j;
                } else {
                    seg_l = j;
                    seg_r = i + 1;
                }

                double old_seg = trip_window_score(order, l, r, seg_l, seg_r, returning);
                relocate_item(order, l, r, i, j);
                double new_seg = trip_window_score(order, l, r, seg_l, seg_r, returning);
                double cand = current - old_seg + new_seg;
                if (cand > current + EPS) {
                    current = cand;
                    improved = 1;
                    any = 1;
                } else {
                    undo_relocate_item(order, l, r, i, j);
                }
            }
        }

        if (!improved) break;
    }
    return any;
}

static int trip_local_reorder(int *src, int *dst) {
    Eval ev;
    unsigned char *starts;
    int any = 0;
    ev = solver_get_trip_eval(src, &starts);
    memcpy(dst, src, (size_t)n * sizeof(int));

    int l = 0;
    while (l < ev.visits) {
        int r = l + 1;
        while (r < ev.visits && !starts[r]) r++;
        any |= improve_trip_range(dst, l, r, r < ev.visits);
        l = r;
    }
    return any;
}

static double trip_window_score(int *order, int trip_l, int trip_r,
                                int l, int r, int returning) {
    double score = 0.0;
    double lx, ly;

    if (l == trip_l) {
        lx = 0.0;
        ly = 0.0;
    } else {
        int prev = order[l - 1];
        lx = cities[prev].x;
        ly = cities[prev].y;
    }

    for (int i = l; i < r; ++i) {
        int id = order[i];
        int carrying = trip_r - i;
        double d = dist2d(lx, ly, cities[id].x, cities[id].y);
        score += factors[visit_level(i)] * cities[id].p
               - d * (1.0 + carry_cost * (double)carrying);
        lx = cities[id].x;
        ly = cities[id].y;
    }

    if (r < trip_r) {
        int next = order[r];
        int carrying = trip_r - r;
        double d = dist2d(lx, ly, cities[next].x, cities[next].y);
        score -= d * (1.0 + carry_cost * (double)carrying);
    } else if (returning && r > trip_l) {
        score -= cities[order[r - 1]].r;
    }

    return score;
}

static int improve_trip_window(int *order, int trip_l, int trip_r,
                               int l, int r, int returning, int passes) {
    int len = r - l;
    int any = 0;
    double current;
    if (len <= 1 || len > 72) return 0;

    current = trip_window_score(order, trip_l, trip_r, l, r, returning);
    for (int pass = 0; pass < passes; ++pass) {
        int improved = 0;

        for (int i = l; i < r && !improved; ++i) {
            for (int j = i + 1; j < r && !improved; ++j) {
                int t = order[i];
                order[i] = order[j];
                order[j] = t;
                double cand = trip_window_score(order, trip_l, trip_r, l, r, returning);
                if (cand > current + EPS) {
                    current = cand;
                    improved = 1;
                    any = 1;
                } else {
                    t = order[i];
                    order[i] = order[j];
                    order[j] = t;
                }
            }
        }

        for (int i = l; i < r && !improved; ++i) {
            for (int j = i + 2; j <= r && !improved; ++j) {
                reverse_range(order, i, j);
                double cand = trip_window_score(order, trip_l, trip_r, l, r, returning);
                if (cand > current + EPS) {
                    current = cand;
                    improved = 1;
                    any = 1;
                } else {
                    reverse_range(order, i, j);
                }
            }
        }

        if (!improved) break;
    }

    return any;
}

static int trip_window_reorder(int *src, int *dst, int window, int stride,
                               int passes, int rounds) {
    Eval ev;
    unsigned char *starts;
    int any = 0;
    ev = solver_get_trip_eval(src, &starts);
    memcpy(dst, src, (size_t)n * sizeof(int));

    int trip_l = 0;
    while (trip_l < ev.visits) {
        int trip_r = trip_l + 1;
        int returning;
        while (trip_r < ev.visits && !starts[trip_r]) trip_r++;
        returning = trip_r < ev.visits;

        if (trip_r - trip_l <= window) {
            any |= improve_trip_window(dst, trip_l, trip_r, trip_l, trip_r, returning, passes);
        } else {
            for (int round = 0; round < rounds; ++round) {
                for (int l = trip_l; l < trip_r; l += stride) {
                    int r = l + window;
                    if (r > trip_r) r = trip_r;
                    any |= improve_trip_window(dst, trip_l, trip_r, l, r, returning, passes);
                }
                if (trip_r - window > trip_l) {
                    any |= improve_trip_window(dst, trip_l, trip_r, trip_r - window,
                                               trip_r, returning, passes);
                }
            }
        }

        trip_l = trip_r;
    }
    return any;
}

static int cmp_trip_blocks(const void *a, const void *b) {
    const TripBlock *ta = (const TripBlock *)a;
    const TripBlock *tb = (const TripBlock *)b;
    if (ta->key < tb->key) return 1;
    if (ta->key > tb->key) return -1;
    if (ta->tie < tb->tie) return 1;
    if (ta->tie > tb->tie) return -1;
    return ta->l - tb->l;
}

static double trip_pair_revenue(int *src, const TripBlock *first,
                                const TripBlock *second, int pos) {
    double revenue = 0.0;
    int cur = pos;

    for (int i = first->l; i < first->r; ++i) {
        revenue += factors[visit_level(cur++)] * cities[src[i]].p;
    }
    for (int i = second->l; i < second->r; ++i) {
        revenue += factors[visit_level(cur++)] * cities[src[i]].p;
    }

    return revenue;
}

static int trip_block_reorder(int *src, int *dst, int mode) {
    Eval ev;
    unsigned char *starts;
    TripBlock *blocks;
    int any = 0;
    ensure_solver_workspace();
    ev = solver_get_trip_eval(src, &starts);
    blocks = solver_trip_blocks;
    memcpy(dst, src, (size_t)n * sizeof(int));

    int count = 0;
    int l = 0;
    while (l < ev.visits) {
        int r = l + 1;
        while (r < ev.visits && !starts[r]) r++;

        double sum = 0.0;
        double mx = -INF;
        double front = 0.0;
        double weight_sum = 0.0;
        for (int i = l; i < r; ++i) {
            double p = cities[src[i]].p;
            double w = (double)(r - i);
            sum += p;
            front += p * w;
            weight_sum += w;
            if (p > mx) mx = p;
        }

        int len = r - l;
        blocks[count].l = l;
        blocks[count].r = r;
        if (mode == 0 || mode == 3 || (mode >= 7 && mode <= 9)
            || (mode >= 11 && mode <= 16)) {
            blocks[count].key = sum / (double)len;
            blocks[count].tie = sum;
        } else if (mode == 1) {
            blocks[count].key = sum;
            blocks[count].tie = sum / (double)len;
        } else if (mode == 4 || mode == 10) {
            blocks[count].key = front / weight_sum;
            blocks[count].tie = sum / (double)len;
        } else if (mode == 5) {
            blocks[count].key = sum / sqrt((double)len);
            blocks[count].tie = sum / (double)len;
        } else if (mode == 6) {
            blocks[count].key = sum / pow((double)len, 0.75);
            blocks[count].tie = sum / (double)len;
        } else {
            blocks[count].key = mx;
            blocks[count].tie = sum / (double)len;
        }
        count++;
        l = r;
    }

    qsort(blocks, (size_t)count, sizeof(TripBlock), cmp_trip_blocks);
    if (mode == 3) {
        int max_passes = 2;
        for (int pass = 0; pass < max_passes; ++pass) {
            int changed = 0;
            int pos = 0;
            for (int b = 0; b + 1 < count; ++b) {
                double keep = trip_pair_revenue(src, &blocks[b], &blocks[b + 1], pos);
                double swapped = trip_pair_revenue(src, &blocks[b + 1], &blocks[b], pos);
                if (swapped > keep + EPS) {
                    TripBlock tmp = blocks[b];
                    blocks[b] = blocks[b + 1];
                    blocks[b + 1] = tmp;
                    changed = 1;
                }
                pos += blocks[b].r - blocks[b].l;
            }
            if (!changed) break;
        }
    }
    if (((mode >= 7 && mode <= 16) || mode == 10) && count > 2) {
        int from = (mode >= 13 && mode <= 16)
            ? 0
            : ((mode == 8 || mode == 9) ? (count / 2) : (count * 2) / 3);
        int rank = (mode == 11 || mode == 14) ? 1 : ((mode == 12 || mode == 15) ? 2 : 0);
        int top_idx[3] = {-1, -1, -1};
        double top_score[3] = {-INF, -INF, -INF};
        for (int b = from; b < count; ++b) {
            double ret = cities[src[blocks[b].r - 1]].r;
            if (mode == 9 || mode == 16) ret -= 0.12 * blocks[b].key;
            for (int t = 0; t < 3; ++t) {
                if (ret > top_score[t]) {
                    for (int u = 2; u > t; --u) {
                        top_score[u] = top_score[u - 1];
                        top_idx[u] = top_idx[u - 1];
                    }
                    top_score[t] = ret;
                    top_idx[t] = b;
                    break;
                }
            }
        }
        int best = top_idx[rank] >= 0 ? top_idx[rank] : top_idx[0];
        if (best + 1 < count) {
            TripBlock chosen = blocks[best];
            for (int b = best; b + 1 < count; ++b) blocks[b] = blocks[b + 1];
            blocks[count - 1] = chosen;
        }
    }

    int pos = 0;
    for (int b = 0; b < count; ++b) {
        for (int i = blocks[b].l; i < blocks[b].r; ++i) {
            any |= (src[pos] != src[i]);
            dst[pos++] = src[i];
        }
    }
    for (int i = ev.visits; i < n; ++i) dst[pos++] = src[i];
    return any;
}

static int popcount_int(int x) {
#if defined(__GNUC__) || defined(__clang__)
    return __builtin_popcount((unsigned int)x);
#else
    int c = 0;
    while (x) {
        x &= x - 1;
        c++;
    }
    return c;
#endif
}

static int ctz_int(int x) {
#if defined(__GNUC__) || defined(__clang__)
    return __builtin_ctz((unsigned int)x);
#else
    int c = 0;
    while ((x & 1) == 0) {
        x >>= 1;
        c++;
    }
    return c;
#endif
}

static int exact_optimize_small_trip(int *order, int l, int r, int returning,
                                     double *tdp, signed char *par) {
    int m = r - l;
    // If the segment length exceeds our runtime threshold, skip exact optimisation.
    if (m <= 1 || m > global_trip_max || m > EXACT_TRIP_MAX) return 0;

    int states = 1 << m;
    int cells_count = states * m;
    for (int i = 0; i < cells_count; ++i) {
        tdp[i] = -INF;
    }

    int ids[EXACT_TRIP_MAX];
    for (int i = 0; i < m; ++i) ids[i] = order[l + i];

    double dist[EXACT_TRIP_MAX][EXACT_TRIP_MAX];
    for (int i = 0; i < m; ++i) {
        int ia = ids[i];
        dist[i][i] = 0.0;
        for (int j = i + 1; j < m; ++j) {
            int ib = ids[j];
            double d = dist2d(cities[ia].x, cities[ia].y,
                              cities[ib].x, cities[ib].y);
            dist[i][j] = d;
            dist[j][i] = d;
        }
    }

    for (int i = 0; i < m; ++i) {
        int id = ids[i];
        int level = visit_level(l);
        double score = factors[level] * cities[id].p
                     - cities[id].r * (1.0 + carry_cost * (double)m);
        int idx = ((1 << i) * m) + i;
        tdp[idx] = score;
        par[idx] = -1;
    }

    for (int mask = 1; mask < states; ++mask) {
        int used = popcount_int(mask);
        if (used >= m) continue;
        int level = visit_level(l + used);
        double weight = 1.0 + carry_cost * (double)(m - used);
        double rev = factors[level];
        int rem_all = (states - 1) ^ mask;

        for (int last = 0; last < m; ++last) {
            int row = mask * m;
            double cur = tdp[row + last];
            if (cur <= -INF / 2.0) continue;

            int rem = rem_all;
            while (rem) {
                int bit = rem & -rem;
                int nxt = ctz_int(bit);
                int nxt_id = ids[nxt];
                int nmask = mask | bit;
                double cand = cur + rev * cities[nxt_id].p - dist[last][nxt] * weight;
                int idx = nmask * m + nxt;
                if (cand > tdp[idx] + EPS) {
                    tdp[idx] = cand;
                    par[idx] = (signed char)last;
                }
                rem ^= bit;
            }
        }
    }

    int full = states - 1;
    int best_last = -1;
    double best_score = -INF;
    for (int last = 0; last < m; ++last) {
        double cand = tdp[full * m + last];
        if (returning) cand -= cities[ids[last]].r;
        if (cand > best_score + EPS) {
            best_score = cand;
            best_last = last;
        }
    }
    if (best_last < 0) return 0;

    int rebuilt[EXACT_TRIP_MAX];
    int changed = 0;
    int mask = full;
    int last = best_last;
    for (int pos = m - 1; pos >= 0; --pos) {
        rebuilt[pos] = ids[last];
        signed char prev = par[mask * m + last];
        mask ^= (1 << last);
        last = (int)prev;
        if (pos > 0 && last < 0) return 0;
    }

    for (int i = 0; i < m; ++i) {
        changed |= (order[l + i] != rebuilt[i]);
    }
    if (changed) {
        for (int i = 0; i < m; ++i) order[l + i] = rebuilt[i];
    }
    return changed;
}

static int trip_exact_small_reorder(int *src, int *dst) {
    Eval ev;
    unsigned char *starts;
    double *tdp;
    signed char *par;
    int any = 0;
    ensure_solver_workspace();
    ev = solver_get_trip_eval(src, &starts);
    tdp = solver_exact_tdp;
    par = solver_exact_par;
    memcpy(dst, src, (size_t)n * sizeof(int));

    long long budget;
    if (n <= 1000) budget = 1200000000LL;
    else if (n <= 20000) budget = 350000000LL;
    else if (n <= 45000) budget = 160000000LL;
    else budget = 120000000LL;
    if (probe_in_range()) {
        long long cap = PROBE_EXACT_BUDGET_CAP;
        if (n >= 49000 && n <= PROBE_BLOCK_HIGH_N &&
            PROBE_EXACT_BUDGET_CAP_50K > 0LL) {
            cap = PROBE_EXACT_BUDGET_CAP_50K;
        } else if (n >= PROBE_BLOCK_LOW_N && n <= PROBE_BLOCK_HIGH_N &&
                   PROBE_EXACT_BUDGET_CAP_BLOCK > 0LL) {
            cap = PROBE_EXACT_BUDGET_CAP_BLOCK;
        } else if (n > PROBE_BLOCK_HIGH_N &&
                   PROBE_EXACT_BUDGET_CAP_AFTER_BLOCK > 0LL) {
            cap = PROBE_EXACT_BUDGET_CAP_AFTER_BLOCK;
        }
        if (cap > 0LL) {
            budget = cap;
        } else if (budget < PROBE_EXACT_BUDGET) {
            budget = PROBE_EXACT_BUDGET;
        }
    }
    int l = 0;
    while (l < ev.visits) {
        int r = l + 1;
        while (r < ev.visits && !starts[r]) r++;
        int m = r - l;
        // Compute an upper bound on the cost of optimising a segment of length m. We
        // only proceed with exact optimisation if the segment length does not
        // exceed the current dynamic threshold and if the estimated number of
        // operations fits within the remaining budget. The term `(1 << m) * m * m`
        // approximates the cost of the bitmask DP in `exact_optimize_small_trip`.
        long long ops = (m <= global_trip_max)
            ? ((long long)1 << m) * m * m
            : budget + 1;
        if (m <= global_trip_max && ops <= budget) {
            any |= exact_optimize_small_trip(dst, l, r, r < ev.visits, tdp, par);
            budget -= ops;
        }
        l = r;
    }
    return any;
}

static void probe_light_candidate(int *order, int *base,
                                  int *best_order, Eval *best_eval) {
    int profile = PROBE_PROFILE;
    int saved_trip_max = global_trip_max;
    double alpha = 5.0 + carry_cost;

    if (profile == 21) alpha = 8.0 + 2.0 * carry_cost;
    else if (profile == 22) alpha = 12.0 + 2.0 * carry_cost;
    else if (profile == 23) alpha = 0.25 + 0.25 * carry_cost;
    else if (profile == 24) alpha = 1.25 + 0.75 * carry_cost;
    else if (profile == 25) alpha = 2.75 + carry_cost;
    else if (profile == 26) alpha = 6.0 + 3.0 * carry_cost;
    else if (profile == 27) alpha = 10.0 + 4.0 * carry_cost;
    else if (profile == 28) alpha = 0.0;
    else if (profile == 29) alpha = 3.5 + 1.5 * carry_cost;
    else if (profile >= 30) alpha = 10.0 + 4.0 * carry_cost;

    sort_order(base, 0, alpha);
    consider_candidate(base, best_order, best_eval);

    if (profile == 20) {
        block_polar_bucket_order(order, base, 96, 32, 36, 0);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 21) {
        block_polar_bucket_order(order, base, 96, 64, 12, 0);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 22) {
        block_cell_order(order, base);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 23) {
        block_spatial_order(order, base, 4);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 24) {
        block_spatial_order_offset(order, base, 1, TWO_PI / 8.0);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 25) {
        bucket_score_order(order, 96, 32, 0, 0, 3, 3);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 26) {
        block_polar_bucket_order(order, base, 96, 32, 48, 1);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 27) {
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 28) {
        sort_order(base, 2, 0.0);
        block_polar_bucket_order(order, base, 96, 64, 24, 0);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 29) {
        block_cell_column_order(order, base);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 7);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 30) {
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        block_cell_column_order(order, base);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 31) {
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 32) {
        block_polar_bucket_order(order, base, 96, 32, 48, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 33) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 34) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 35) {
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 7);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 13);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 36) {
        bucket_score_order(order, 96, 32, 24, 0, 3, 3);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 37) {
        trip_nearest_reorder(best_order, order, 0.0, 1.0);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 38) {
        trip_window_reorder(best_order, order, 32, 16, 2, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 40) {
        trip_window_reorder(best_order, order, 24, 12, 1, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 41) {
        trip_window_reorder(best_order, order, 28, 14, 2, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 42) {
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 24, 12, 1, 1);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 43) {
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 32, 16, 1, 1);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 44) {
        trip_window_reorder(best_order, order, 32, 16, 3, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 45) {
        trip_window_reorder(best_order, order, 40, 20, 2, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 46) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 24, 12, 1, 1);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 47) {
        trip_window_reorder(best_order, order, 24, 8, 2, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 48) {
        trip_window_reorder(best_order, order, 36, 12, 2, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 49) {
        trip_window_reorder(best_order, order, 32, 8, 2, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 50) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 51) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 52) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 20, 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 53) {
        trip_window_reorder(best_order, order, 20, 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 54) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 16, 8, 1, 1);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 55) {
        if (time_ok(0.2)) {
            consider_candidate_if_changed(
                trip_block_reorder(best_order, order, 3),
                order, best_order, best_eval);
            consider_candidate_if_changed(
                trip_block_reorder(best_order, order, 7),
                order, best_order, best_eval);
            consider_candidate_if_changed(
                trip_block_reorder(best_order, order, 13),
                order, best_order, best_eval);
        }
        if (global_trip_max < 11) global_trip_max = 11;
        if (time_ok(0.1)) {
            consider_candidate_if_changed(
                trip_exact_small_reorder(best_order, order),
                order, best_order, best_eval);
        }
        if (time_ok(0.05)) {
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 24, 12, 1, 1),
                order, best_order, best_eval);
            consider_candidate_if_changed(
                trip_exact_small_reorder(best_order, order),
                order, best_order, best_eval);
        }
    } else if (profile == 56) {
        sort_order(base, 0, 2.0 + carry_cost);
        build_greedy_order(order, base, 9, 6, 0.65 + 0.35 * carry_cost,
                           1.0 + 0.55 * carry_cost, 12, 521288629u);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 20, 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 57) {
        sort_order(base, 0, 4.0 + 2.0 * carry_cost);
        build_greedy_order(order, base, 12, 5, 0.45 + 0.25 * carry_cost,
                           0.7 + 0.45 * carry_cost, 18, 122949829u);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 24, 12, 1, 1);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    } else if (profile == 58 || profile == 59 || profile == 64 || profile == 65) {
        if (global_trip_max < 11) global_trip_max = 11;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 20, 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
    } else {
        block_polar_bucket_order(order, base, 96, 64, 24, 0);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
        if (global_trip_max < 10) global_trip_max = 10;
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    }

    global_trip_max = saved_trip_max;
}

static void probe_medium_candidate(int *order, int *base,
                                   int *best_order, Eval *best_eval) {
    int saved_trip_max = global_trip_max;
    int profile = PROBE_PROFILE;
    double alphas[] = {
        0.25 + 0.25 * carry_cost,
        0.75 + 0.5 * carry_cost,
        1.5 + carry_cost,
        3.0 + carry_cost,
        6.0 + 2.0 * carry_cost
    };
    int alpha_count = (int)(sizeof(alphas) / sizeof(alphas[0]));
    double mult = 1.0;
    double shift = 0.0;
    int window = 40;
    int stride = 20;

    if (profile == 2) {
        mult = 0.55;
        window = 48;
    } else if (profile == 3) {
        mult = 1.4;
        shift = 1.0 + carry_cost;
    } else if (profile == 4) {
        mult = 2.2;
        shift = 3.0 + carry_cost;
        window = 36;
        stride = 18;
    } else if (profile >= 5) {
        mult = 0.8 + 0.25 * (double)(profile % 5);
        shift = 0.5 * (double)(profile % 4) + 0.5 * carry_cost;
        window = 44 + 4 * (profile % 4);
        stride = 16 + 2 * (profile % 3);
    }

    global_trip_max = EXACT_TRIP_MAX > 12 ? 12 : EXACT_TRIP_MAX;

    for (int a = 0; a < alpha_count; ++a) {
        sort_order(base, 0, shift + mult * alphas[a]);
        consider_candidate(base, best_order, best_eval);

        block_cell_order(order, base);
        consider_candidate(order, best_order, best_eval);

        block_cell_column_order(order, base);
        consider_candidate(order, best_order, best_eval);

        block_polar_bucket_order(order, base, 96, 32, (a * 12 + 6 * profile) % 96, 0);
        consider_candidate(order, best_order, best_eval);
        if (profile >= 4) {
            block_polar_bucket_order(order, base, 96, 64, (a * 12 + 24) % 96, 1);
            consider_candidate(order, best_order, best_eval);
        }
    }

    sort_order(base, 2, 0.0);
    block_cell_order(order, base);
    consider_candidate(order, best_order, best_eval);

    bucket_score_order(order, 96, 32, 8 * (profile % 6), 0, profile % 4, profile % 4);
    consider_candidate(order, best_order, best_eval);
    bucket_score_order(order, 96, 64, 24 + 4 * profile, 1, (profile + 1) % 4, (profile + 2) % 4);
    consider_candidate(order, best_order, best_eval);

    if (profile >= 3) {
        sort_order(base, 0, shift + mult * (1.5 + carry_cost));
        build_greedy_order(order, base, 5 + (profile % 4), 6,
                           0.9 + 0.3 * carry_cost,
                           1.2 + 0.7 * carry_cost,
                           8, 2463534242u + (unsigned int)profile);
        consider_candidate(order, best_order, best_eval);
    }

    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    trip_block_reorder(best_order, order, 3);
    consider_candidate(order, best_order, best_eval);
    trip_block_reorder(best_order, order, 7);
    consider_candidate(order, best_order, best_eval);
    trip_block_reorder(best_order, order, 13);
    consider_candidate(order, best_order, best_eval);

    trip_nearest_reorder(best_order, order, 0.0, 1.0);
    consider_candidate(order, best_order, best_eval);

    trip_window_reorder(best_order, order, window, stride, 3, 1);
    consider_candidate(order, best_order, best_eval);

    global_trip_max = saved_trip_max;
}

static void probe_aggressive_candidate(int *order, int *base,
                                       int *best_order, Eval *best_eval) {
    int saved_trip_max;
    int profile = PROBE_PROFILE;
    int modes[] = {3, 4, 5, 6, 2, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    int mode_count = (int)(sizeof(modes) / sizeof(modes[0]));
    double alpha_base[] = {0.0, 0.25, 0.75, 1.5, 3.0, 6.0, 10.0, 16.0, 24.0};
    double alpha_carry[] = {0.0, 0.25, 0.5, 1.0, 1.0, 2.0, 2.0, 3.0, 4.0};
    int alpha_count = (int)(sizeof(alpha_base) / sizeof(alpha_base[0]));
    double alpha_mult = 1.0;
    double alpha_shift = 0.0;
    int window_a = 64;
    int window_b = 72;
    int window_c = 48;
    int stride_a = 32;
    int stride_b = 24;
    int stride_c = 16;
    int window_passes = 5;
    int window_rounds = 2;

    if (!probe_in_range()) return;

    if (n >= PROBE_BLOCK_LOW_N && n <= PROBE_BLOCK_HIGH_N) {
        if (profile == 64 || profile == 65 || profile == 66) {
            /* let the specialized aggressive branch below run */
        } else if (profile >= 20) {
            probe_light_candidate(order, base, best_order, best_eval);
            return;
        } else {
            probe_medium_candidate(order, base, best_order, best_eval);
            return;
        }
    }

    if (profile == 2) {
        alpha_mult = 0.55;
        window_a = 72;
        window_b = 64;
        window_c = 56;
    } else if (profile == 3) {
        alpha_mult = 1.75;
        alpha_shift = 2.0 + carry_cost;
        window_a = 56;
        window_b = 72;
        window_c = 48;
    } else if (profile == 4) {
        alpha_mult = 2.75;
        alpha_shift = 5.0 + 2.0 * carry_cost;
        stride_a = 24;
        stride_b = 18;
    } else if (profile == 5) {
        alpha_mult = 0.8;
        window_a = 72;
        window_b = 72;
        stride_a = 18;
        stride_b = 18;
        window_passes = 7;
        window_rounds = 3;
    } else if (profile == 6) {
        alpha_mult = 1.25;
        alpha_shift = 1.0;
        window_a = 48;
        window_b = 64;
        window_c = 40;
        stride_a = 16;
        stride_b = 16;
        stride_c = 12;
    } else if (profile == 7) {
        alpha_mult = 3.5;
        alpha_shift = 10.0 + 3.0 * carry_cost;
        window_a = 40;
        window_b = 56;
        window_c = 40;
        stride_a = 12;
        stride_b = 14;
        stride_c = 10;
    } else if (profile == 8) {
        alpha_mult = 0.35;
        window_a = 72;
        window_b = 72;
        window_c = 64;
        stride_a = 36;
        stride_b = 24;
    } else if (profile == 9) {
        alpha_mult = 1.0;
        alpha_shift = 4.0 + carry_cost;
        window_a = 64;
        window_b = 48;
        window_c = 72;
        stride_a = 16;
        stride_b = 12;
        stride_c = 18;
        window_passes = 8;
        window_rounds = 3;
    } else if (profile >= 10) {
        alpha_mult = 2.0;
        alpha_shift = 14.0 + 4.0 * carry_cost;
        window_a = 72;
        window_b = 64;
        window_c = 72;
        stride_a = 12;
        stride_b = 16;
        stride_c = 12;
        window_passes = 9;
        window_rounds = 3;
    }

    if (profile == 58 || profile == 59 || profile == 60 || profile == 61) {
        saved_trip_max = global_trip_max;
        global_trip_max = EXACT_TRIP_MAX > 12 ? 12 : EXACT_TRIP_MAX;

        sort_order(base, 0, (profile == 59 ? 3.0 : 1.5) + carry_cost);
        build_seed_cluster_order(order, base, profile == 60 ? 14 : 10,
                                 profile == 61 ? 14 : 10,
                                 profile == 59 ? 8 : 6,
                                 profile == 59 ? (0.45 + 0.25 * carry_cost)
                                               : (0.75 + 0.35 * carry_cost),
                                 profile == 59 ? (0.8 + 0.5 * carry_cost)
                                               : (1.2 + 0.6 * carry_cost),
                                 profile == 60 ? 120.0 : 60.0,
                                 profile == 61 ? 20 : 12,
                                 2885390081u);
        consider_candidate(order, best_order, best_eval);

        trip_nearest_reorder(best_order, order, 0.0, 1.0);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, profile == 61 ? 28 : 20,
                            profile == 61 ? 14 : 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);

        sort_order(base, 2, 0.0);
        build_seed_cluster_order(order, base, profile == 60 ? 16 : 12,
                                 8, 8, 0.65 + 0.25 * carry_cost,
                                 1.0 + 0.4 * carry_cost,
                                 profile == 59 ? 100.0 : 50.0,
                                 10, 362436069u);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, 20, 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);

        global_spatial_order(order, 4, 0.0);
        consider_candidate(order, best_order, best_eval);
        bucket_score_order(order, 128, 64, 32, profile == 59, 3, 1);
        consider_candidate(order, best_order, best_eval);

        global_trip_max = saved_trip_max;
        return;
    }

    if (profile == 62 || profile == 63) {
        saved_trip_max = global_trip_max;
        global_trip_max = EXACT_TRIP_MAX > 12 ? 12 : EXACT_TRIP_MAX;

        sort_order(base, 0, 1.0 + carry_cost);
        block_nearest_order(order, base, 10, 18, 0.0, 1.0);
        consider_candidate(order, best_order, best_eval);
        block_nearest_order(order, base, 14, 14, 0.01, 0.8 + 0.2 * carry_cost);
        consider_candidate(order, best_order, best_eval);

        sort_order(base, 0, 2.0 + carry_cost);
        block_nearest_order(order, base, 12, 16, 0.005, 1.0 + 0.3 * carry_cost);
        consider_candidate(order, best_order, best_eval);

        sort_order(base, 2, 0.0);
        block_nearest_order(order, base, 10, 14, 0.02, 0.75 + 0.2 * carry_cost);
        consider_candidate(order, best_order, best_eval);

        bucket_score_order(order, 128, 64, profile == 63 ? 32 : 16, 0, 3, 1);
        consider_candidate(order, best_order, best_eval);
        trip_nearest_reorder(best_order, order, 0.0, 1.0);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, profile == 63 ? 28 : 24,
                            profile == 63 ? 14 : 12, 1, 1);
        consider_candidate(order, best_order, best_eval);
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);

        global_trip_max = saved_trip_max;
        return;
    }

    if (profile == 64 || profile == 65 || profile == 66) {
        saved_trip_max = global_trip_max;
        global_trip_max = EXACT_TRIP_MAX > 12 ? 12 : EXACT_TRIP_MAX;

        sort_order(base, 0, profile == 65 ? (3.0 + carry_cost) : (1.5 + carry_cost));
        build_kd_greedy_order(order, base,
                              profile == 66 ? (0.55 + 0.25 * carry_cost)
                                            : (0.80 + 0.30 * carry_cost),
                              profile == 65 ? (0.9 + 0.45 * carry_cost)
                                            : (1.2 + 0.55 * carry_cost),
                              profile == 65 ? (0.10 * carry_cost)
                                            : (0.16 * carry_cost));
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, profile == 66 ? 28 : 20,
                            profile == 66 ? 14 : 10, 1, 1);
        consider_candidate(order, best_order, best_eval);
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);

        sort_order(base, 2, 0.0);
        build_kd_greedy_order(order, base,
                              profile == 65 ? (0.45 + 0.20 * carry_cost)
                                            : (0.70 + 0.25 * carry_cost),
                              0.9 + 0.35 * carry_cost,
                              0.12 * carry_cost);
        consider_candidate(order, best_order, best_eval);
        trip_nearest_reorder(best_order, order, 0.0, 1.0);
        consider_candidate(order, best_order, best_eval);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, best_eval);
        if (time_ok(0.12)) {
            global_spatial_order(order, 4, 0.0);
            consider_candidate(order, best_order, best_eval);
        }

        global_trip_max = saved_trip_max;
        return;
    }

    saved_trip_max = global_trip_max;
    global_trip_max = EXACT_TRIP_MAX;

    global_spatial_order(order, 0, 0.0);
    consider_candidate(order, best_order, best_eval);
    global_spatial_order(order, 4, 0.0);
    consider_candidate(order, best_order, best_eval);
    global_spatial_order(order, 1, 0.0);
    consider_candidate(order, best_order, best_eval);
    global_spatial_order(order, 1, TWO_PI / 8.0);
    consider_candidate(order, best_order, best_eval);
    global_spatial_order(order, 3, 0.0);
    consider_candidate(order, best_order, best_eval);

    bucket_score_order(order, 96, 32, 0, 0, profile % 4, profile % 4);
    consider_candidate(order, best_order, best_eval);
    bucket_score_order(order, 96, 64, 24, 0, (profile + 1) % 4, (profile + 2) % 4);
    consider_candidate(order, best_order, best_eval);
    bucket_score_order(order, 64, 64, 0, 1, (profile + 2) % 4, (profile + 1) % 4);
    consider_candidate(order, best_order, best_eval);
    if (profile >= 5) {
        bucket_score_order(order, 128, 32, 16, 0, 3, 3);
        consider_candidate(order, best_order, best_eval);
        bucket_score_order(order, 128, 64, 48, 1, 1, 1);
        consider_candidate(order, best_order, best_eval);
    }

    for (int a = 0; a < alpha_count; ++a) {
        double alpha = alpha_shift + alpha_mult * (alpha_base[a] + alpha_carry[a] * carry_cost);
        sort_order(base, 0, alpha);
        consider_candidate(base, best_order, best_eval);

        block_cell_order(order, base);
        consider_candidate(order, best_order, best_eval);
        for (int l = 0; l < n; l += block_size) {
            int r = l + block_size;
            if (r > n) r = n;
            reverse_range(order, l, r);
        }
        consider_candidate(order, best_order, best_eval);

        block_cell_column_order(order, base);
        consider_candidate(order, best_order, best_eval);
        for (int l = 0; l < n; l += block_size) {
            int r = l + block_size;
            if (r > n) r = n;
            reverse_range(order, l, r);
        }
        consider_candidate(order, best_order, best_eval);

        block_polar_bucket_order(order, base, 96, 64, (a * 12) % 96, 0);
        consider_candidate(order, best_order, best_eval);
        if (profile >= 4) {
            block_polar_bucket_order(order, base, 96, 64, (a * 12 + 48) % 96, 1);
            consider_candidate(order, best_order, best_eval);
        }
        if ((a & 1) == 0 || profile >= 5) {
            block_spatial_order(order, base, 1);
            consider_candidate(order, best_order, best_eval);

            block_spatial_order(order, base, 3);
            consider_candidate(order, best_order, best_eval);

            block_spatial_order_offset(order, base, 1, TWO_PI / 8.0);
            consider_candidate(order, best_order, best_eval);

            block_radial_cell_order(order, base, 96);
            consider_candidate(order, best_order, best_eval);
        }
    }

    sort_order(base, 2, 0.0);
    consider_candidate(base, best_order, best_eval);
    block_cell_order(order, base);
    consider_candidate(order, best_order, best_eval);
    block_polar_bucket_order(order, base, 96, 64, 18, 0);
    consider_candidate(order, best_order, best_eval);

    sort_order(base, 0, alpha_shift + alpha_mult * (1.5 + carry_cost));
    build_greedy_order(order, base, 7 + (profile % 4), 8, 1.0 + 0.5 * carry_cost,
                       1.4 + carry_cost, 12, 88675123u);
    consider_candidate(order, best_order, best_eval);

    build_greedy_order(order, base, 10 + (profile % 5), 6, 0.7 + 0.35 * carry_cost,
                       0.9 + 0.7 * carry_cost, 10, 362436069u);
    consider_candidate(order, best_order, best_eval);

    if (profile >= 3) {
        build_greedy_order(order, base, 14, 5, 0.45 + 0.25 * carry_cost,
                           0.55 + 0.4 * carry_cost, 16, 123456789u);
        consider_candidate(order, best_order, best_eval);
    }

    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    trip_nearest_reorder(best_order, order, 0.0, 1.0);
    consider_candidate(order, best_order, best_eval);

    trip_nearest_reorder(best_order, order, 0.02, 0.85 + 0.4 * carry_cost);
    consider_candidate(order, best_order, best_eval);

    trip_window_reorder(best_order, order, window_a, stride_a, window_passes, window_rounds);
    consider_candidate(order, best_order, best_eval);

    for (int i = 0; i < mode_count; ++i) {
        trip_block_reorder(best_order, order, modes[i]);
        consider_candidate(order, best_order, best_eval);
        if ((i & 3) == 3) {
            trip_exact_small_reorder(best_order, order);
            consider_candidate(order, best_order, best_eval);
            trip_window_reorder(best_order, order, window_a, stride_a, window_passes - 1, 1);
            consider_candidate(order, best_order, best_eval);
        }
    }

    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    trip_window_reorder(best_order, order, window_b, stride_b, window_passes - 1, window_rounds);
    consider_candidate(order, best_order, best_eval);

    deep_trip_polish = 1;
    trip_local_reorder(best_order, order);
    deep_trip_polish = 0;
    consider_candidate(order, best_order, best_eval);

    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    trip_window_reorder(best_order, order, window_c, stride_c, window_passes, window_rounds);
    consider_candidate(order, best_order, best_eval);

    trip_block_reorder(best_order, order, 3);
    consider_candidate(order, best_order, best_eval);
    trip_block_reorder(best_order, order, 13);
    consider_candidate(order, best_order, best_eval);

    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    if (profile >= 5) {
        trip_block_reorder(best_order, order, 9);
        consider_candidate(order, best_order, best_eval);
        trip_window_reorder(best_order, order, window_b, stride_c, window_passes, 1);
        consider_candidate(order, best_order, best_eval);
        trip_exact_small_reorder(best_order, order);
        consider_candidate(order, best_order, best_eval);
    }

    global_trip_max = saved_trip_max;
}

static void boost_large_45k_candidate(int *order, int *base,
                                      int *best_order, Eval *best_eval) {
    int saved_trip_max;

    if (n <= 45000) return;

    saved_trip_max = global_trip_max;
    if (global_trip_max < 10) global_trip_max = 10;

    sort_order(base, 0, 1.0 + carry_cost);
    consider_candidate(base, best_order, best_eval);
    sort_order(base, 2, 0.0);
    block_polar_bucket_order(order, base, 96, 64, 24, 0);
    consider_candidate(order, best_order, best_eval);
    bucket_score_order(order, 128, 64, 32, 0, 3, 1);
    consider_candidate(order, best_order, best_eval);
    block_spatial_order(order, base, 1);
    consider_candidate(order, best_order, best_eval);
    block_spatial_order_offset(order, base, 1, TWO_PI / 8.0);
    consider_candidate(order, best_order, best_eval);

    trip_window_reorder(best_order, order, 24, 12, 1, 1);
    consider_candidate(order, best_order, best_eval);
    trip_block_reorder(best_order, order, 3);
    consider_candidate(order, best_order, best_eval);
    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    global_spatial_order(order, 4, 0.0);
    consider_candidate(order, best_order, best_eval);
    bucket_score_order(order, 128, 64, 32, 0, 3, 1);
    consider_candidate(order, best_order, best_eval);
    trip_nearest_reorder(best_order, order, 0.0, 1.0);
    consider_candidate(order, best_order, best_eval);
    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, best_eval);

    global_trip_max = saved_trip_max;
}

static void shuffle_range(int *a, int l, int r, unsigned int *seed) {
    for (int i = r - 1; i > l; --i) {
        int j = l + (int)(rng_next(seed) % (unsigned int)(i - l + 1));
        int t = a[i];
        a[i] = a[j];
        a[j] = t;
    }
}

static void reverse_range(int *a, int l, int r) {
    --r;
    while (l < r) {
        int t = a[l];
        a[l] = a[r];
        a[r] = t;
        ++l;
        --r;
    }
}

static void local_search_candidates(int *work, int *best_order, Eval *best_eval) {
    int rounds;
    if (n <= 20) rounds = 40000;
    else if (n <= 100) rounds = 8000;
    else if (n <= 1000) rounds = 1200;
    else rounds = 0;
    if (rounds <= 0) return;

    unsigned int seed = 987654321u;
    int *cur = (int *)malloc((size_t)n * sizeof(int));
    if (!cur) exit(1);

    for (int t = 0; t < rounds; ++t) {
        memcpy(cur, best_order, (size_t)n * sizeof(int));

        if ((t & 3) == 0) {
            int l = (int)(rng_next(&seed) % (unsigned int)n);
            int r = (int)(rng_next(&seed) % (unsigned int)n);
            if (l > r) {
                int tmp = l;
                l = r;
                r = tmp;
            }
            if (r < n) r++;
            reverse_range(cur, l, r);
        } else if ((t & 3) == 1) {
            int a = (int)(rng_next(&seed) % (unsigned int)n);
            int b = (int)(rng_next(&seed) % (unsigned int)n);
            int tmp = cur[a];
            cur[a] = cur[b];
            cur[b] = tmp;
        } else if ((t & 3) == 2) {
            int l = (int)(rng_next(&seed) % (unsigned int)n);
            int len = 2 + (int)(rng_next(&seed) % (unsigned int)(n < 20 ? n : 20));
            int r = l + len;
            if (r > n) r = n;
            shuffle_range(cur, l, r, &seed);
        } else {
            int l = ((int)(rng_next(&seed) % 10u)) * block_size;
            int r = l + block_size;
            if (l >= n) l = 0;
            if (r > n) r = n;
            shuffle_range(cur, l, r, &seed);
        }

        Eval ev = evaluate_order(cur, 0);
        if (ev.profit > best_eval->profit + EPS) {
            *best_eval = ev;
            memcpy(best_order, cur, (size_t)n * sizeof(int));
        }
    }

    memcpy(work, best_order, (size_t)n * sizeof(int));
    free(cur);
}

static int next_permutation_int(int *a, int len) {
    int i = len - 2;
    while (i >= 0 && a[i] > a[i + 1]) i--;
    if (i < 0) return 0;

    int j = len - 1;
    while (a[j] < a[i]) j--;

    int t = a[i];
    a[i] = a[j];
    a[j] = t;

    for (int l = i + 1, r = len - 1; l < r; ++l, --r) {
        t = a[l];
        a[l] = a[r];
        a[r] = t;
    }
    return 1;
}

static double exact_trip_cost(int *order, int l, int r, int returning,
                              double *ps, double *pt) {
    int first = order[l - 1];
    int last = order[r - 1];
    double h = cities[first].r;
    double edges = ps[r] - ps[l];
    double weighted = ((double)(r + 1)) * edges - (pt[r] - pt[l]);
    double cost = h + edges + carry_cost * ((double)(r - l + 1) * h + weighted);
    if (returning) cost += cities[last].r;
    return cost;
}

static void exact_small_candidate(int *work, int *best_order, Eval *best_eval) {
    if (n > 10) return;

    double *ps = (double *)malloc((size_t)(n + 1) * sizeof(double));
    double *pt = (double *)malloc((size_t)(n + 1) * sizeof(double));
    double *rdp = (double *)malloc((size_t)(n + 1) * sizeof(double));
    double *rev = (double *)malloc((size_t)(n + 1) * sizeof(double));
    if (!ps || !pt || !rdp || !rev) exit(1);

    for (int i = 0; i < n; ++i) work[i] = i;

    do {
        ps[0] = ps[1] = 0.0;
        pt[0] = pt[1] = 0.0;
        for (int i = 2; i <= n; ++i) {
            City *a = &cities[work[i - 2]];
            City *b = &cities[work[i - 1]];
            double e = dist2d(a->x, a->y, b->x, b->y);
            ps[i] = ps[i - 1] + e;
            pt[i] = pt[i - 1] + (double)i * e;
        }

        rev[0] = 0.0;
        for (int i = 1; i <= n; ++i) {
            int level = visit_level(i - 1);
            rev[i] = rev[i - 1] + factors[level] * cities[work[i - 1]].p;
        }

        rdp[0] = 0.0;
        for (int r = 1; r <= n; ++r) {
            rdp[r] = INF;
            for (int l = 1; l <= r; ++l) {
                double v = rdp[l - 1] + exact_trip_cost(work, l, r, 1, ps, pt);
                if (v < rdp[r]) rdp[r] = v;
            }
        }

        for (int r = 1; r <= n; ++r) {
            for (int l = 1; l <= r; ++l) {
                double cost = rdp[l - 1] + exact_trip_cost(work, l, r, 0, ps, pt);
                double profit = rev[r] - cost;
                if (profit > best_eval->profit + EPS) {
                    best_eval->profit = profit;
                    best_eval->visits = r;
                    best_eval->final_l = l;
                    memcpy(best_order, work, (size_t)n * sizeof(int));
                }
            }
        }
    } while (next_permutation_int(work, n));

    free(ps);
    free(pt);
    free(rdp);
    free(rev);
}

static void write_solution(FILE *out, int *order, Eval best, unsigned char *starts) {
    if (best.visits <= 0) return;

    for (int i = 0; i < best.visits; ++i) {
        int id = order[i];
        if (starts[i]) {
            int count = 1;
            while (i + count < best.visits && !starts[i + count]) count++;
            fprintf(out, "%s %s %d\n", cities[id].xs, cities[id].ys, count);
        } else {
            fprintf(out, "%s %s\n", cities[id].xs, cities[id].ys);
        }

        if (i + 1 < best.visits && starts[i + 1]) {
            fprintf(out, "0 0\n");
        }
    }
}

static double direct_profit(int *order, Eval best, unsigned char *starts) {
    double revenue = 0.0;
    double cost = 0.0;
    double lx = 0.0, ly = 0.0;
    int carrying = 0;

    for (int i = 0; i < best.visits; ++i) {
        int id = order[i];
        if (starts[i]) {
            carrying = 1;
            while (i + carrying < best.visits && !starts[i + carrying]) carrying++;
            lx = 0.0;
            ly = 0.0;
        }

        double d = dist2d(lx, ly, cities[id].x, cities[id].y);
        cost += d * (1.0 + carry_cost * (double)carrying);
        revenue += factors[visit_level(i)] * cities[id].p;
        carrying--;

        lx = cities[id].x;
        ly = cities[id].y;

        if (i + 1 < best.visits && starts[i + 1]) {
            cost += cities[id].r;
            carrying = 0;
        }
    }

    return revenue - cost;
}

static double kd_now_seconds(void) {
    return (double)clock() / (double)CLOCKS_PER_SEC;
}

static double kd_test_rand01(unsigned int *seed) {
    return (double)(rng_next(seed) & 0x00ffffffu) / 16777216.0;
}

static double kd_test_rand_range(unsigned int *seed, double lo, double hi) {
    return lo + (hi - lo) * kd_test_rand01(seed);
}

static int kd_test_rand_int(unsigned int *seed, int lo, int hi) {
    unsigned int span = (unsigned int)(hi - lo + 1);
    return lo + (int)(rng_next(seed) % span);
}

static double kd_test_clamp(double v, double lo, double hi) {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
}

static void kd_test_set_factor(double factor) {
    for (int i = 0; i < LEVELS; ++i) factors[i] = factor;
}

static void kd_test_reset_instance(void) {
    kd_release_tree();
    release_solver_workspace();
    free(cities);
    cities = NULL;
    n = 0;
    hq_city = -1;
}

static void kd_test_alloc_case(int count) {
    kd_test_reset_instance();
    n = count;
    cities = (City *)calloc((size_t)n, sizeof(City));
    if (!cities) exit(1);
}

static void kd_test_fill_case(int count, int pattern, unsigned int *seed) {
    double cx[4];
    double cy[4];
    kd_test_alloc_case(count);
    carry_cost = kd_test_rand_range(seed, 0.05, 0.85);
    drop_factor = 0.97;
    kd_test_set_factor(1.0);

    for (int i = 0; i < 4; ++i) {
        cx[i] = kd_test_rand_range(seed, -800.0, 800.0);
        cy[i] = kd_test_rand_range(seed, -800.0, 800.0);
    }

    for (int i = 0; i < n; ++i) {
        double x, y;
        double p;
        if (pattern == 0) {
            x = kd_test_rand_range(seed, -1000.0, 1000.0);
            y = kd_test_rand_range(seed, -1000.0, 1000.0);
        } else if (pattern == 1) {
            int c = kd_test_rand_int(seed, 0, 3);
            x = cx[c] + kd_test_rand_range(seed, -120.0, 120.0);
            y = cy[c] + kd_test_rand_range(seed, -120.0, 120.0);
        } else {
            x = kd_test_rand_range(seed, -980.0, 980.0);
            y = 0.57 * x + 35.0 + kd_test_rand_range(seed, -2.0, 2.0);
        }
        x = kd_test_clamp(x, -1000.0, 1000.0);
        y = kd_test_clamp(y, -1000.0, 1000.0);
        p = kd_test_rand_range(seed, 40.0, 4000.0);

        cities[i].x = x;
        cities[i].y = y;
        cities[i].p = p;
        cities[i].r = hypot(x, y);
        cities[i].used = 0;
    }
}

static double kd_test_score_city(int id, double x, double y, int pos,
                                 double lambda, double radial_penalty) {
    double dx = x - cities[id].x;
    double dy = y - cities[id].y;
    double factor = factors[visit_level(pos)];
    return factor * cities[id].p
         - radial_penalty * cities[id].r
         - lambda * sqrt(dx * dx + dy * dy);
}

static int kd_test_bruteforce_best(double x, double y, int pos,
                                   double lambda, double radial_penalty,
                                   double initial_score, double *score_out) {
    int best = -1;
    double best_score = initial_score;
    for (int i = 0; i < n; ++i) {
        double score;
        if (!kd_city_node || kd_city_node[i] < 0 || cities[i].used) continue;
        score = kd_test_score_city(i, x, y, pos, lambda, radial_penalty);
        if (score > best_score + EPS) {
            best_score = score;
            best = i;
        }
    }
    *score_out = best_score;
    return best;
}

static void kd_test_mark_used(int id) {
    if (id < 0 || id >= n || cities[id].used) return;
    cities[id].used = 1;
    kd_deactivate_city(id);
}

static int kd_test_compare_query(double x, double y, int pos, double lambda,
                                 double radial_penalty, double initial_score,
                                 const char *tag, int verbose) {
    double kd_score = initial_score;
    double brute_score = initial_score;
    int kd_id = kd_best_city(x, y, pos, lambda, radial_penalty, initial_score, &kd_score);
    int brute_id = kd_test_bruteforce_best(x, y, pos, lambda, radial_penalty, initial_score, &brute_score);

    if (fabs(kd_score - brute_score) > 1e-7) {
        fprintf(stderr,
                "[kd-test] score mismatch tag=%s kd=%d brute=%d kd_score=%.12f brute_score=%.12f pos=%d lambda=%.12g radial=%.12g initial=%.12f\n",
                tag, kd_id, brute_id, kd_score, brute_score, pos, lambda, radial_penalty, initial_score);
        return 0;
    }

    if (kd_id != brute_id) {
        double kd_exact = (kd_id >= 0) ? kd_test_score_city(kd_id, x, y, pos, lambda, radial_penalty) : initial_score;
        double brute_exact = (brute_id >= 0) ? kd_test_score_city(brute_id, x, y, pos, lambda, radial_penalty) : initial_score;
        if (fabs(kd_exact - brute_exact) > 1e-7) {
            fprintf(stderr,
                    "[kd-test] id mismatch tag=%s kd=%d brute=%d kd_exact=%.12f brute_exact=%.12f pos=%d lambda=%.12g radial=%.12g\n",
                    tag, kd_id, brute_id, kd_exact, brute_exact, pos, lambda, radial_penalty);
            return 0;
        }
    }

    if (verbose) {
        double kd_score2 = initial_score;
        double kd_score3 = initial_score;
        int kd_id2 = kd_best_city(x, y, pos, lambda, radial_penalty, initial_score, &kd_score2);
        int kd_id3 = kd_best_city(x, y, pos, lambda, radial_penalty, initial_score, &kd_score3);
        if (kd_id2 != kd_id3 || fabs(kd_score2 - kd_score3) > 1e-12) {
            fprintf(stderr,
                    "[kd-test] nondeterminism tag=%s first=(%d,%.12f) second=(%d,%.12f)\n",
                    tag, kd_id2, kd_score2, kd_id3, kd_score3);
            return 0;
        }
    }

    return 1;
}

static int kd_run_property_tests(void) {
    static const double lambda_values[] = {0.0, 1e-12, 1e-6, 1e-3, 0.1, 1.0, 25.0, 1000.0};
    static const double radial_values[] = {0.0, 1e-12, 1e-6, 1e-3, 0.1, 1.0, 8.0, 64.0};
    static const double factor_values[] = {0.05, 0.2, 1.0, 2.5, 9.0};
    unsigned int seed = 0xC0FFEE11u;
    int query_checks = 0;
    int large_subset_checks = 0;

    for (int pattern = 0; pattern < 3; ++pattern) {
        for (int case_id = 0; case_id < 8; ++case_id) {
            int count = kd_test_rand_int(&seed, 100, 5000);
            kd_test_fill_case(count, pattern, &seed);
            ensure_kd_tree();

            for (int round = 0; round < 12; ++round) {
                kd_reset_active();
                for (int i = 0; i < n; ++i) cities[i].used = 0;

                {
                    int deactivate_count = kd_test_rand_int(&seed, 0, n / 6 + 1);
                    for (int t = 0; t < deactivate_count; ++t) {
                        kd_test_mark_used(kd_test_rand_int(&seed, 0, n - 1));
                    }
                }

                for (int q = 0; q < 48; ++q) {
                    double factor = factor_values[kd_test_rand_int(&seed, 0, (int)(sizeof(factor_values) / sizeof(factor_values[0])) - 1)];
                    double lambda = lambda_values[kd_test_rand_int(&seed, 0, (int)(sizeof(lambda_values) / sizeof(lambda_values[0])) - 1)];
                    double radial = radial_values[kd_test_rand_int(&seed, 0, (int)(sizeof(radial_values) / sizeof(radial_values[0])) - 1)];
                    double x = kd_test_rand_range(&seed, -1200.0, 1200.0);
                    double y = kd_test_rand_range(&seed, -1200.0, 1200.0);
                    double initial = kd_test_rand_range(&seed, -5000.0, 5000.0);
                    int pos = kd_test_rand_int(&seed, 0, n - 1);

                    kd_test_set_factor(factor);
                    if (!kd_test_compare_query(x, y, pos, lambda, radial, initial, "property", q == 0 && round == 0)) {
                        kd_test_reset_instance();
                        return 0;
                    }
                    ++query_checks;
                }
            }
        }
    }

    kd_test_fill_case(50000, 1, &seed);
    ensure_kd_tree();
    for (int round = 0; round < 8; ++round) {
        kd_reset_active();
        for (int i = 0; i < n; ++i) cities[i].used = 0;
        for (int t = 0; t < 3000; ++t) kd_test_mark_used(kd_test_rand_int(&seed, 0, n - 1));

        for (int q = 0; q < 16; ++q) {
            double factor = factor_values[kd_test_rand_int(&seed, 0, (int)(sizeof(factor_values) / sizeof(factor_values[0])) - 1)];
            double lambda = lambda_values[kd_test_rand_int(&seed, 0, (int)(sizeof(lambda_values) / sizeof(lambda_values[0])) - 1)];
            double radial = radial_values[kd_test_rand_int(&seed, 0, (int)(sizeof(radial_values) / sizeof(radial_values[0])) - 1)];
            double x = kd_test_rand_range(&seed, -1200.0, 1200.0);
            double y = kd_test_rand_range(&seed, -1200.0, 1200.0);
            int pos = kd_test_rand_int(&seed, 0, n - 1);

            kd_test_set_factor(factor);
            if (!kd_test_compare_query(x, y, pos, lambda, radial, -INF, "subset", q == 0 && round == 0)) {
                kd_test_reset_instance();
                return 0;
            }
            ++large_subset_checks;
        }
    }

    kd_reset_active();
    for (int i = 0; i < n; ++i) kd_test_mark_used(i);
    kd_test_set_factor(1.0);
    if (!kd_test_compare_query(0.0, 0.0, 0, 1.0, 0.5, 123.0, "all-used", 0)) {
        kd_test_reset_instance();
        return 0;
    }

    fprintf(stderr,
            "[kd-test] ok property_queries=%d subset_queries=%d leaf=%d subset_n=%d\n",
            query_checks, large_subset_checks, KD_LEAF_SIZE, kd_subset_n);
    kd_test_reset_instance();
    return 1;
}

static int kd_run_benchmarks(void) {
    const int build_sizes[] = {10000, 50000, 100000};
    const double factor_values[] = {0.05, 0.2, 1.0, 2.5, 9.0};
    unsigned int seed = 0x12345678u;

    for (int i = 0; i < (int)(sizeof(build_sizes) / sizeof(build_sizes[0])); ++i) {
        double t0, t1;
        kd_test_fill_case(build_sizes[i], 0, &seed);
        t0 = kd_now_seconds();
        ensure_kd_tree();
        t1 = kd_now_seconds();
        fprintf(stderr,
                "[kd-bench] build n=%d kd_n=%d nodes=%d leaf=%d time_ms=%.3f\n",
                build_sizes[i], kd_subset_n, kd_count, KD_LEAF_SIZE, 1000.0 * (t1 - t0));
    }

    kd_test_fill_case(100000, 1, &seed);
    ensure_kd_tree();
    kd_reset_active();
    for (int i = 0; i < kd_subset_n / 5; ++i) kd_test_mark_used(kd_test_rand_int(&seed, 0, n - 1));
    kd_test_set_factor(1.0);
    kd_perf_enabled = 1;
    kd_reset_perf_stats();

    {
        const int query_count = 100000;
        double t0 = kd_now_seconds();
        long long checksum = 0;
        double accum = 0.0;
        for (int q = 0; q < query_count; ++q) {
            double factor = factor_values[q % 5];
            double lambda = 0.05 + 2.5 * kd_test_rand01(&seed);
            double radial = 0.0 + 0.75 * kd_test_rand01(&seed);
            double x = kd_test_rand_range(&seed, -1200.0, 1200.0);
            double y = kd_test_rand_range(&seed, -1200.0, 1200.0);
            double score = -INF;
            int pos = kd_test_rand_int(&seed, 0, n - 1);
            int id;

            kd_test_set_factor(factor);
            id = kd_best_city(x, y, pos, lambda, radial, -INF, &score);
            checksum += (long long)(id + 2);
            accum += score;
        }

        kd_perf_enabled = 0;
        fprintf(stderr,
                "[kd-bench] query n=%d kd_n=%d q=%d time_ms=%.3f visited=%llu checked=%llu sqrt=%llu pruned=%llu checksum=%lld accum=%.6f\n",
                n, kd_subset_n, query_count, 1000.0 * (kd_now_seconds() - t0),
                kd_perf_stats.visited_nodes,
                kd_perf_stats.checked_points,
                kd_perf_stats.sqrt_evaluations,
                kd_perf_stats.prune_count,
                checksum, accum);
    }

    kd_test_reset_instance();
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        if (strcmp(argv[1], "--kd-test") == 0) {
            return kd_run_property_tests() ? 0 : 1;
        }
        if (strcmp(argv[1], "--kd-bench") == 0) {
            return kd_run_benchmarks() ? 0 : 1;
        }
        if (strcmp(argv[1], "--kd-test-bench") == 0) {
            if (!kd_run_property_tests()) return 1;
            return kd_run_benchmarks() ? 0 : 1;
        }
    }

    FILE *in = stdin;
    FILE *out = stdout;
    int file_mode = 0;
    g_start_time = (double)clock() / (double)CLOCKS_PER_SEC;
    setvbuf(stdin, NULL, _IOFBF, 1 << 20);
    setvbuf(stdout, NULL, _IOFBF, 1 << 20);

    if (fscanf(in, "%d %lf %lf", &n, &carry_cost, &drop_factor) != 3) {
        in = fopen("input.txt", "r");
        if (!in) return 0;
        out = fopen("output.txt", "w");
        if (!out) out = stdout;
        setvbuf(in, NULL, _IOFBF, 1 << 20);
        if (out != stdout) setvbuf(out, NULL, _IOFBF, 1 << 20);
        file_mode = 1;
        if (fscanf(in, "%d %lf %lf", &n, &carry_cost, &drop_factor) != 3) {
            if (file_mode && in) fclose(in);
            if (file_mode && out && out != stdout) fclose(out);
            return 0;
        }
    }
    if (drop_factor > 1.0) drop_factor /= 100.0;

    // Adjust the effective maximum trip size used in exact optimisation based on
    // the total number of cities. For very large inputs, using a smaller
    // threshold dramatically reduces the number of expensive dynamic
    // programming computations performed by `exact_optimize_small_trip`. The
    // thresholds below were chosen experimentally to balance runtime and
    // solution quality across different input sizes. The compileвЂ‘time limit
    // EXACT_TRIP_MAX should be large enough to accommodate the highest
    // possible dynamic limit.
    if (n > 45000) {
        global_trip_max = 12;
    } else if (n > 30000) {
        global_trip_max = 9;
    } else if (n > 15000) {
        global_trip_max = 10;
    } else if (n > 5000) {
        global_trip_max = 11;
    } else {
        global_trip_max = 12;
    }
    if (global_trip_max > EXACT_TRIP_MAX) {
        global_trip_max = EXACT_TRIP_MAX;
    }

    cities = (City *)calloc((size_t)n, sizeof(City));
    if (!cities) return 1;

    for (int i = 0; i < n; ++i) {
        if (fscanf(in, "%63s %63s %lf", cities[i].xs, cities[i].ys, &cities[i].p) != 3) {
            return 1;
        }
        cities[i].x = strtod(cities[i].xs, NULL);
        cities[i].y = strtod(cities[i].ys, NULL);
        cities[i].r = hypot(cities[i].x, cities[i].y);
        cities[i].angle96 = angle_bucket(cities[i].x, cities[i].y, 96, 0);
        cities[i].morton = morton_code(cities[i].x, cities[i].y);
        cities[i].hilbert = hilbert_code(cities[i].x, cities[i].y);
        if (fabs(cities[i].x) < EPS && fabs(cities[i].y) < EPS) hq_city = i;
    }

    {
        const double pi = acos(-1.0);
        for (int i = 0; i < n; ++i) {
            cities[i].ang = atan2(cities[i].y, cities[i].x);
            if (cities[i].ang < 0.0) cities[i].ang += 2.0 * pi;
        }
    }

    int large_enable_bnear = 0;
    int large_spiral_like = 0;
    if (n > 45000) {
        double minx = cities[0].x, maxx = cities[0].x;
        double miny = cities[0].y, maxy = cities[0].y;
        int row_bins[32] = {0};
        int col_bins[32] = {0};
        unsigned char occ[32 * 32] = {0};
        int *ids = (int *)malloc((size_t)n * sizeof(int));
        int unique_x = 0, unique_y = 0;
        int grid_nonempty = 0;
        double row_max_share = 0.0, col_max_share = 0.0;
        if (!ids) return 1;

        for (int i = 0; i < n; ++i) {
            ids[i] = i;
            if (cities[i].x < minx) minx = cities[i].x;
            if (cities[i].x > maxx) maxx = cities[i].x;
            if (cities[i].y < miny) miny = cities[i].y;
            if (cities[i].y > maxy) maxy = cities[i].y;
        }

        qsort(ids, (size_t)n, sizeof(int), cmp_x_ids);
        unique_x = n > 0 ? 1 : 0;
        for (int i = 1; i < n; ++i) {
            if (fabs(cities[ids[i]].x - cities[ids[i - 1]].x) > EPS) unique_x++;
        }

        qsort(ids, (size_t)n, sizeof(int), cmp_y_ids);
        unique_y = n > 0 ? 1 : 0;
        for (int i = 1; i < n; ++i) {
            if (fabs(cities[ids[i]].y - cities[ids[i - 1]].y) > EPS) unique_y++;
        }
        free(ids);

        {
            double w = maxx - minx;
            double h = maxy - miny;
            for (int i = 0; i < n; ++i) {
                int gx = 0, gy = 0;
                if (w > EPS) gx = (int)(((cities[i].x - minx) / (w + EPS)) * 32.0);
                if (h > EPS) gy = (int)(((cities[i].y - miny) / (h + EPS)) * 32.0);
                if (gx < 0) gx = 0;
                else if (gx >= 32) gx = 31;
                if (gy < 0) gy = 0;
                else if (gy >= 32) gy = 31;
                col_bins[gx]++;
                row_bins[gy]++;
                occ[gy * 32 + gx] = 1;
            }
            for (int i = 0; i < 32; ++i) {
                double rs = (double)row_bins[i] / (double)n;
                double cs = (double)col_bins[i] / (double)n;
                if (rs > row_max_share) row_max_share = rs;
                if (cs > col_max_share) col_max_share = cs;
            }
            for (int i = 0; i < 32 * 32; ++i) {
                grid_nonempty += occ[i] ? 1 : 0;
            }
        }

        {
            int hi = unique_x > unique_y ? unique_x : unique_y;
            int lo = unique_x > unique_y ? unique_y : unique_x;
            double axis_ratio = (double)hi / (double)(lo > 0 ? lo : 1);
            int spiral_like = (grid_nonempty > 800 &&
                               row_max_share > 0.07 &&
                               col_max_share > 0.07 &&
                               axis_ratio < 2.5);
            large_spiral_like = spiral_like;
            large_enable_bnear = (!spiral_like &&
                                  (grid_nonempty < 900 ||
                                   row_max_share > 0.06 ||
                                   col_max_share > 0.06 ||
                                   axis_ratio > 8.0));
        }
    }

    block_size = n / 10;
    if (block_size < 1) block_size = 1;
    factors[0] = 1.0;
    for (int i = 1; i < LEVELS; ++i) factors[i] = factors[i - 1] * drop_factor;

    build_grid();

    pref_s = (double *)malloc((size_t)(n + 2) * sizeof(double));
    pref_t = (double *)malloc((size_t)(n + 2) * sizeof(double));
    dp = (double *)malloc((size_t)(n + 2) * sizeof(double));
    parent_ret = (int *)malloc((size_t)(n + 2) * sizeof(int));
    tree_xmax = n + 1;
    tree = (Line *)calloc((size_t)(4 * (tree_xmax + 2)), sizeof(Line));

    int *order = (int *)malloc((size_t)n * sizeof(int));
    int *base = (int *)malloc((size_t)n * sizeof(int));
    int *best_order = (int *)malloc((size_t)n * sizeof(int));
    unsigned char *starts = (unsigned char *)calloc((size_t)n, sizeof(unsigned char));
    if (!pref_s || !pref_t || !dp || !parent_ret || !tree ||
        !order || !base || !best_order || !starts) {
        return 1;
    }

    for (int i = 0; i < n; ++i) order[i] = i;
    Eval best = evaluate_order(order, 0);
    memcpy(best_order, order, (size_t)n * sizeof(int));
    solver_refresh_best_cache(best_order);

    for (int i = 0; i < n; ++i) order[i] = n - 1 - i;
    consider_candidate(order, best_order, &best);

    if (n > 45000) {
        sort_order(order, 0, 1.0 + carry_cost);
        consider_candidate(order, best_order, &best);
        memcpy(base, order, (size_t)n * sizeof(int));

        sort_order(order, 0, 3.0 + carry_cost);
        consider_candidate(order, best_order, &best);
        sort_order(order, 0, 0.25 + 0.25 * carry_cost);
        consider_candidate(order, best_order, &best);
        sort_order(order, 1, 0.0);
        consider_candidate(order, best_order, &best);
        sort_order(order, 2, 0.0);
        consider_candidate(order, best_order, &best);
        global_spatial_order(order, 4, 0.0);
        consider_candidate(order, best_order, &best);
        global_spatial_order(order, 1, 0.0);
        consider_candidate(order, best_order, &best);
        sort_order(base, 0, 1.0 + carry_cost);
        prefix_spatial_order(order, base, 20000, 4, 0.0);
        consider_candidate(order, best_order, &best);
        prefix_spatial_order(order, base, 30000, 1, 0.0);
        consider_candidate(order, best_order, &best);

        sort_order(base, 0, 1.0 + carry_cost);
        block_cell_order(order, base);
        consider_candidate(order, best_order, &best);
        block_cell_column_order(order, base);
        consider_candidate(order, best_order, &best);
        block_polar_bucket_order(order, base, 96, 32, 0, 0);
        consider_candidate(order, best_order, &best);
        block_polar_bucket_order(order, base, 96, 32, 24, 0);
        consider_candidate(order, best_order, &best);
        block_polar_bucket_order(order, base, 96, 64, 48, 0);
        consider_candidate(order, best_order, &best);

        sort_order(base, 2, 0.0);
        consider_candidate(base, best_order, &best);
        block_polar_bucket_order(order, base, 96, 64, 24, 0);
        consider_candidate(order, best_order, &best);
        block_cell_order(order, base);
        consider_candidate(order, best_order, &best);
        consider_candidate_if_changed(
            block_nearest_order(order, base, 6, 10, 0.02, 1.0 + 0.5 * carry_cost),
            order, best_order, &best);

        if (n >= 49000 && time_ok(0.35)) {
            probe_aggressive_candidate(order, base, best_order, &best);
        }

        consider_candidate_if_changed(
            trip_window_reorder(best_order, order, 40, 20, 1, 1),
            order, best_order, &best);
        consider_candidate_if_changed(
            trip_exact_small_reorder(best_order, order),
            order, best_order, &best);
        consider_candidate_if_changed(
            trip_window_reorder(best_order, order, 24, 12, 1, 1),
            order, best_order, &best);

        sort_order(base, 0, 1.0 + carry_cost);
        build_kd_greedy_order(order, base,
                              0.80 + 0.30 * carry_cost,
                              1.2 + 0.55 * carry_cost,
                              0.16 * carry_cost);
        consider_candidate(order, best_order, &best);

        sort_order(base, 2, 0.0);
        build_kd_greedy_order(order, base,
                              0.70 + 0.25 * carry_cost,
                              0.9 + 0.35 * carry_cost,
                              0.12 * carry_cost);
        consider_candidate(order, best_order, &best);

        if (time_ok(0.4)) {
            consider_candidate_if_changed(
                trip_nearest_reorder(best_order, order, 0.0, 1.0),
                order, best_order, &best);
        }
        consider_candidate_if_changed(
            trip_exact_small_reorder(best_order, order),
            order, best_order, &best);
        if (time_ok(0.0)) {
            consider_candidate_if_changed(
                trip_block_reorder(best_order, order, 3),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_block_reorder(best_order, order, 7),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_block_reorder(best_order, order, 13),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_exact_small_reorder(best_order, order),
                order, best_order, &best);
        }
        if (time_ok(0.0)) {
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 16, 8, 1, 1),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 12, 6, 1, 1),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 8, 4, 1, 1),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 4, 2, 1, 1),
                order, best_order, &best);
        }

        if (time_ok(0.15)) {
            bucket_score_order(order, 128, 64, 32, 0, 3, 1);
            consider_candidate(order, best_order, &best);
            sort_order(base, 2, 0.0);
            block_spatial_order(order, base, 1);
            consider_candidate(order, best_order, &best);
            block_spatial_order_offset(order, base, 1, TWO_PI / 8.0);
            consider_candidate(order, best_order, &best);
        }

        if (large_enable_bnear && time_ok(0.3)) {
            sort_order(base, 0, 1.0 + carry_cost);
            consider_candidate_if_changed(
                block_nearest_order(order, base, 10, 18, 0.0, 1.0),
                order, best_order, &best);
            sort_order(base, 2, 0.0);
            consider_candidate_if_changed(
                block_nearest_order(order, base, 10, 14, 0.02, 0.75 + 0.2 * carry_cost),
                order, best_order, &best);
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 12, 6, 1, 1),
                order, best_order, &best);
        }
        if (large_spiral_like && time_ok(0.4)) {
            sort_order(base, 0, 1.5 + carry_cost);
            build_kd_greedy_order(order, base,
                                  0.55 + 0.25 * carry_cost,
                                  1.2 + 0.55 * carry_cost,
                                  0.16 * carry_cost);
            consider_candidate(order, best_order, &best);
            if (time_ok(0.25)) {
                consider_candidate_if_changed(
                    trip_nearest_reorder(best_order, order, 0.0, 1.0),
                    order, best_order, &best);
            }
            consider_candidate_if_changed(
                trip_window_reorder(best_order, order, 12, 6, 1, 1),
                order, best_order, &best);
        }

        if (time_ok(0.15)) {
            consider_candidate_if_changed(
                trip_local_reorder(best_order, order),
                order, best_order, &best);
        }

        memcpy(base, best_order, (size_t)n * sizeof(int));
        if (time_ok(0.1)) {
            probe_aggressive_candidate(order, base, best_order, &best);
        }
        goto finalize_output;
    }

    if (n <= 20000) {
        double alphas[] = {
            0.0,
            0.25 + 0.25 * carry_cost,
            0.5 + 0.5 * carry_cost,
            carry_cost,
            1.0 + carry_cost,
            2.0 + carry_cost,
            4.0 + carry_cost,
            8.0 + 2.0 * carry_cost
        };
        int alpha_count = (int)(sizeof(alphas) / sizeof(alphas[0]));
        for (int a = 0; a < alpha_count; ++a) {
            sort_order(order, 0, alphas[a]);
            consider_candidate(order, best_order, &best);
        }
    } else {
        sort_order(order, 0, 2.0 + carry_cost);
        consider_candidate(order, best_order, &best);
    }

    sort_order(order, 0, 1.0 + carry_cost);
    consider_candidate(order, best_order, &best);
    memcpy(base, order, (size_t)n * sizeof(int));

    block_cell_order(order, base);
    consider_candidate(order, best_order, &best);
    block_cell_column_order(order, base);
    consider_candidate(order, best_order, &best);
    block_polar_bucket_order(order, base, 96, 32, 0, 0);
    consider_candidate(order, best_order, &best);
    block_polar_bucket_order(order, base, 96, 32, 24, 0);
    consider_candidate(order, best_order, &best);
    if (n > 20000) {
        block_polar_bucket_order(order, base, 96, 64, 48, 0);
        consider_candidate(order, best_order, &best);
    }
    block_radial_cell_order(order, base, 64);
    consider_candidate(order, best_order, &best);

    if (n > 20000) {
        sort_order(base, 2, 0.0);
        block_cell_order(order, base);
        consider_candidate(order, best_order, &best);
        block_cell_column_order(order, base);
        consider_candidate(order, best_order, &best);
        block_polar_bucket_order(order, base, 96, 32, 12, 0);
        consider_candidate(order, best_order, &best);
        block_polar_bucket_order(order, base, 96, 64, 36, 0);
        consider_candidate(order, best_order, &best);
    }

    sort_order(order, 0, 0.5 + 0.5 * carry_cost);
    consider_candidate(order, best_order, &best);

    sort_order(order, 0, 2.0 + carry_cost);
    consider_candidate(order, best_order, &best);

    sort_order(order, 0, 4.0 + carry_cost);
    consider_candidate(order, best_order, &best);

    sort_order(order, 1, 0.0);
    consider_candidate(order, best_order, &best);

    sort_order(order, 2, 0.0);
    consider_candidate(order, best_order, &best);

    sort_order(base, 0, 1.0 + carry_cost);
    block_spatial_order(order, base, 0);
    consider_candidate(order, best_order, &best);
    if (n > 20000) {
        block_spatial_order(order, base, 4);
        consider_candidate(order, best_order, &best);
    }
    {
        block_spatial_order(order, base, 1);
        consider_candidate(order, best_order, &best);
        if (n > 20000) {
            block_spatial_order_offset(order, base, 1, TWO_PI / 8.0);
            consider_candidate(order, best_order, &best);
            block_spatial_order_offset(order, base, 3, TWO_PI / 8.0);
            consider_candidate(order, best_order, &best);
        }
    }
    if (n <= 20000) {
        block_spatial_order_offset(order, base, 1, TWO_PI / 8.0);
        consider_candidate(order, best_order, &best);
        block_spatial_order_offset(order, base, 1, TWO_PI / 4.0);
        consider_candidate(order, best_order, &best);
        block_spatial_order(order, base, 2);
        consider_candidate(order, best_order, &best);
        block_spatial_order(order, base, 3);
        consider_candidate(order, best_order, &best);
        block_spatial_order_offset(order, base, 3, TWO_PI / 8.0);
        consider_candidate(order, best_order, &best);
        block_spatial_order(order, base, 4);
        consider_candidate(order, best_order, &best);
    }
    block_nearest_order(order, base, 6, 10, 0.02, 1.0 + 0.5 * carry_cost);
    consider_candidate(order, best_order, &best);
    if (n <= 20000) {
        block_nearest_order(order, base, 10, 8, 0.01, 0.7 + 0.3 * carry_cost);
        consider_candidate(order, best_order, &best);
    }

    sort_order(base, 0, 2.0 + carry_cost);
    block_spatial_order(order, base, 0);
    consider_candidate(order, best_order, &best);
    if (n <= 20000) {
        block_spatial_order(order, base, 4);
        consider_candidate(order, best_order, &best);
        block_spatial_order(order, base, 1);
        consider_candidate(order, best_order, &best);
        block_spatial_order_offset(order, base, 1, TWO_PI / 6.0);
        consider_candidate(order, best_order, &best);
        block_nearest_order(order, base, 6, 8, 0.015, 1.0 + carry_cost);
        consider_candidate(order, best_order, &best);
    }

    if (n <= 20000) {
        sort_order(base, 2, 0.0);
        block_spatial_order(order, base, 0);
        consider_candidate(order, best_order, &best);
        block_spatial_order(order, base, 4);
        consider_candidate(order, best_order, &best);
        block_spatial_order(order, base, 1);
        consider_candidate(order, best_order, &best);
        block_cell_order(order, base);
        consider_candidate(order, best_order, &best);
        block_nearest_order(order, base, 8, 8, 0.02, 0.9 + 0.2 * carry_cost);
        consider_candidate(order, best_order, &best);
    }

    sort_order(base, 0, 1.5 + carry_cost);
    build_greedy_order(order, base, 5, 7, 1.0 + 0.6 * carry_cost,
                       1.5 + carry_cost, 10, 2463534242u);
    consider_candidate(order, best_order, &best);

    if (n <= 20000) {
        build_greedy_order(order, base, 8, 5, 0.8 + 0.4 * carry_cost,
                           1.0 + carry_cost, 6, 123456789u);
        consider_candidate(order, best_order, &best);

        build_greedy_order(order, base, 12, 5, 0.4 + 0.3 * carry_cost,
                           0.6 + 0.5 * carry_cost, 14, 362436069u);
        consider_candidate(order, best_order, &best);
    }

    if (n <= 20000) {
        sort_order(order, 3, 0.0);
        consider_candidate(order, best_order, &best);
    }

    memcpy(base, best_order, (size_t)n * sizeof(int));

    trip_nearest_reorder(best_order, order, 0.0, 1.0);
    consider_candidate(order, best_order, &best);
    if (n <= 20000) {
        trip_nearest_reorder(best_order, order, 0.01, 1.0 + 0.3 * carry_cost);
        consider_candidate(order, best_order, &best);
    }

    trip_local_reorder(base, order);
    consider_candidate(order, best_order, &best);
    trip_local_reorder(best_order, order);
    consider_candidate(order, best_order, &best);
    if (n <= 20000) {
        trip_local_reorder(best_order, order);
        consider_candidate(order, best_order, &best);
    }

    trip_exact_small_reorder(best_order, order);
    consider_candidate(order, best_order, &best);
    trip_local_reorder(best_order, order);
    consider_candidate(order, best_order, &best);
    if (n > 1000) {
        trip_block_reorder(best_order, order, 0);
        consider_candidate(order, best_order, &best);

        trip_exact_small_reorder(order, base);
        consider_candidate(base, best_order, &best);
        trip_block_reorder(best_order, order, 3);
        consider_candidate(order, best_order, &best);
        if (n > 20000) {
            trip_block_reorder(best_order, order, 7);
            consider_candidate(order, best_order, &best);
            trip_block_reorder(best_order, order, 13);
            consider_candidate(order, best_order, &best);
        }
    }
    probe_aggressive_candidate(order, base, best_order, &best);
    boost_large_45k_candidate(order, base, best_order, &best);
    if (n <= 20000) {
        trip_nearest_reorder(best_order, order, 0.0, 1.0);
        consider_candidate(order, best_order, &best);
    }

    local_search_candidates(order, best_order, &best);

    exact_small_candidate(order, best_order, &best);

finalize_output:
    Eval final_eval = evaluate_order(best_order, 1);
    reconstruct_starts(best_order, final_eval, starts);
    if (direct_profit(best_order, final_eval, starts) <= EPS) {
        final_eval.visits = 0;
    }
    write_solution(out, best_order, final_eval, starts);

    if (file_mode && in && in != stdin) fclose(in);
    if (file_mode && out && out != stdout) fclose(out);
    return 0;
}
