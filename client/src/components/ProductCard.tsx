import { Link } from "wouter";
import { motion } from "framer-motion";
import { Product } from "@/hooks/use-products";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Sparkles, ArrowRight } from "lucide-react";

// Get the base path from Vite's BASE_URL environment variable
const basePath = import.meta.env.BASE_URL.replace(/\/$/, '');

interface ProductCardProps {
  product: Product;
  index: number;
}

export function ProductCard({ product, index }: ProductCardProps) {
  const isSold = product.isSold;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay: index * 0.1 }}
    >
      <Link href={`${basePath}/product/${product.id}`}>
        <Card className="group h-full overflow-hidden bg-card/50 border-white/5 hover:border-primary/50 transition-all duration-300 hover:shadow-[0_0_30px_rgba(139,92,246,0.15)] cursor-pointer backdrop-blur-sm relative">
          <div className="aspect-[4/5] overflow-hidden relative">
            <div className="absolute inset-0 bg-gradient-to-t from-background/90 via-transparent to-transparent z-10 opacity-60 group-hover:opacity-40 transition-opacity duration-500" />
            <img
              src={`${import.meta.env.BASE_URL}${product.imageUrl.replace(/^\//, '')}`}
              alt={product.name}
              className={`w-full h-full object-cover transform transition-transform duration-700 ease-out group-hover:scale-110 ${isSold ? 'grayscale' : ''}`}
            />
            {isSold && (
              <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/40 backdrop-blur-[2px]">
                <Badge variant="destructive" className="text-lg px-6 py-2 font-display tracking-widest border-2 border-destructive uppercase">
                  Sold Out
                </Badge>
              </div>
            )}
            <div className="absolute top-4 right-4 z-20">
              <Badge className="bg-black/50 backdrop-blur-md border border-primary/30 text-primary font-mono hover:bg-black/70 transition-colors">
                {product.category === 'design' ? 'Design' : `NFT #${product.id.toString().padStart(3, '0')}`}
              </Badge>
            </div>
          </div>
          
          <CardContent className="p-6 relative z-20">
            <h3 className="font-display text-xl font-bold tracking-wide text-white group-hover:text-primary transition-colors duration-300 mb-2 truncate">
              {product.name}
            </h3>
            <p className="text-muted-foreground text-sm line-clamp-2 font-light">
              {product.description}
            </p>
          </CardContent>
          
          <CardFooter className="p-6 pt-0 flex items-center justify-between relative z-20 border-t border-white/5 mt-auto">
            <div className="flex flex-col">
              <span className="text-xs text-muted-foreground uppercase tracking-wider font-semibold">Price</span>
              <span className="font-mono text-lg text-white">
                ${(product.price / 100).toFixed(2)}
              </span>
            </div>
            
            <Button 
              size="icon" 
              variant="ghost" 
              className="rounded-full w-10 h-10 bg-white/5 hover:bg-primary hover:text-white transition-all duration-300 group-hover:translate-x-1"
              disabled={isSold}
            >
              {isSold ? <Sparkles className="w-4 h-4 opacity-50" /> : <ArrowRight className="w-4 h-4" />}
            </Button>
          </CardFooter>
        </Card>
      </Link>
    </motion.div>
  );
}
