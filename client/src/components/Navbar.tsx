import { Link } from "wouter";
import { Moon, Menu, X } from "lucide-react";
import { useState } from "react";

// Get the base path from Vite's BASE_URL environment variable
const basePath = import.meta.env.BASE_URL.replace(/\/$/, '');

export function Navbar() {
  const [mobileOpen, setMobileOpen] = useState(false);

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

        {/* Desktop nav */}
        <div className="hidden md:flex items-center space-x-4 md:space-x-6">
          <Link href={basePath + "/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
            Collection
          </Link>
          <Link href={basePath + "/about"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
            Our Story
          </Link>
          <a href={basePath + "/mint/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
            Mint
          </a>
          <a 
            href="https://spiritwolf.dashery.com/" 
            target="_blank" 
            rel="noopener noreferrer"
            className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors"
          >
            Merch
          </a>
        </div>

        {/* Mobile hamburger */}
        <button 
          className="md:hidden text-muted-foreground hover:text-primary transition-colors"
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label="Menu"
        >
          {mobileOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile menu dropdown */}
      {mobileOpen && (
        <div className="md:hidden border-t border-white/5 bg-background/95 backdrop-blur-md">
          <div className="container mx-auto px-4 py-4 flex flex-col space-y-3">
            <Link href={basePath + "/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors py-2" onClick={() => setMobileOpen(false)}>
              Collection
            </Link>
            <Link href={basePath + "/about"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors py-2" onClick={() => setMobileOpen(false)}>
              Our Story
            </Link>
            <a href={basePath + "/mint/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors py-2" onClick={() => setMobileOpen(false)}>
              Mint
            </a>
            <a href={basePath + "/contribute/"} className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors py-2" onClick={() => setMobileOpen(false)}>
              Contribute
            </a>
            <a 
              href="https://spiritwolf.dashery.com/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors py-2"
            >
              Merch
            </a>
          </div>
        </div>
      )}
    </nav>
  );
}
