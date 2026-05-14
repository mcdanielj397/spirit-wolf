import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  // Base path for GitHub Pages - update this to match your repo name
  // For user/org pages (username.github.io), use "/"
  // For project pages (username.github.io/repo-name), use "/repo-name/"
  // Use "/" in development, repo name in production
  base: process.env.NODE_ENV === "production" ? "/" : "/",
  
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(import.meta.dirname, "client", "src"),
      "@assets": path.resolve(import.meta.dirname, "attached_assets"),
    },
  },
  root: path.resolve(import.meta.dirname, "client"),
  build: {
    outDir: path.resolve(import.meta.dirname, "dist"),
    emptyOutDir: true,
  },
  server: {
    fs: {
      strict: true,
      deny: ["**/.*"],
    },
  },
});
