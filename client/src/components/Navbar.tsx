import { Link } from "wouter";
import { Moon } from "lucide-react";

// Get the base path from Vite's BASE_URL environment variable
const basePath = import.meta.env.BASE_URL.replace(/\/$/, '');

export function Navbar() {
  return (
    <nav className="fixed top-0 w-full z-50 border-b border-white/5 bg-background/60 backdrop-blur-md transition-all duration-300">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        <Link href={basePath + "/"} className="flex items-center space-x-2 group">
          <div className="bg-primary/20 p-2 rounded-full group-hover:bg-primary/30 transition-colors">
            <Moon className="w-5 h-5 text-primary animate-pulse" />
          </div>
          <span className="font-display text-xl md:text-2xl font-bold tracking-widest text-foreground group-hover:text-primary transition-colors">
            SPIRIT WOLF
          </span>
        </Link>

        <div className="flex items-center space-x-4 md:space-x-6">
          <Link href={basePath + "/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors hidden md:block">
            Collection
          </Link>
          <Link href={basePath + "/about"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors hidden md:block">
            Our Story
          </Link>
          <a href={basePath + "/mint/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors hidden md:block">
            Mint
          </a>
          <a 
            href="https://spiritwolf.dashery.com/" 
            target="_blank" 
            rel="noopener noreferrer"
            className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors hidden md:block"
          >
            Merch
          </a>
        </div>
      </div>
    </nav>
  );
}
