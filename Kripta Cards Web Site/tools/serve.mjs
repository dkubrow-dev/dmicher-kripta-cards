import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, "..");
const distDir = path.join(rootDir, "dist");
const port = Number(process.env.PORT || 4173);

const mimeTypes = new Map([
  [".html", "text/html; charset=utf-8"],
  [".css", "text/css; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".xml", "application/xml; charset=utf-8"],
  [".txt", "text/plain; charset=utf-8"],
  [".svg", "image/svg+xml"],
  [".zip", "application/zip"],
  [".bat", "application/octet-stream"],
  [".sh", "text/x-shellscript; charset=utf-8"]
]);

createServer(async (request, response) => {
  try {
    const url = new URL(request.url || "/", `http://localhost:${port}`);
    const filePath = await resolveFile(url.pathname);
    const body = await readFile(filePath);
    response.writeHead(200, {
      "content-type": mimeTypes.get(path.extname(filePath)) || "application/octet-stream"
    });
    response.end(body);
  } catch {
    const fallback = path.join(distDir, "404.html");
    response.writeHead(404, { "content-type": "text/html; charset=utf-8" });
    response.end(await readFile(fallback));
  }
}).listen(port, () => {
  console.log(`Kripta Cards site: http://localhost:${port}/`);
});

async function resolveFile(urlPath) {
  const safePath = decodeURIComponent(urlPath).replace(/^\/+/, "");
  let candidate = path.join(distDir, safePath);
  const root = path.resolve(distDir);
  if (!path.resolve(candidate).startsWith(root)) {
    throw new Error("Path traversal blocked");
  }

  const candidateStat = await stat(candidate).catch(() => null);
  if (candidateStat?.isDirectory()) {
    candidate = path.join(candidate, "index.html");
  } else if (!candidateStat && !path.extname(candidate)) {
    candidate = path.join(candidate, "index.html");
  }

  await stat(candidate);
  return candidate;
}
