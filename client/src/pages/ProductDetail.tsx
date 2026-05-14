import { useRoute, Link } from "wouter";
import { motion } from "framer-motion";
import { useProduct, createPurchaseIssueUrl } from "@/hooks/use-products";
import { Navbar } from "@/components/Navbar";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { ArrowLeft, Check, ShieldCheck, Zap, Sparkles, ExternalLink } from "lucide-react";

// Get the base path from Vite's BASE_URL environment variable
const basePath = import.meta.env.BASE_URL.replace(/\/$/, '');

export default function ProductDetail() {
  const [, params] = useRoute(basePath + "/product/:id");
  const id = params ? parseInt((params as Record<string, string>).id) : 0;
  
  const { data: product, isLoading } = useProduct(id);

  const handlePurchase = () => {
    if (!product) return;
    const issueUrl = createPurchaseIssueUrl(product);
    window.open(issueUrl, "_blank");
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-32">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
            <Skeleton className="aspect-[4/5] rounded-xl bg-white/5" />
            <div className="space-y-6">
              <Skeleton className="h-12 w-3/4 bg-white/5" />
              <Skeleton className="h-6 w-1/4 bg-white/5" />
              <Skeleton className="h-32 w-full bg-white/5" />
              <Skeleton className="h-16 w-full rounded-full bg-white/5" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!product) return <div>Product not found</div>;

  return (
    <div className="min-h-screen bg-background selection:bg-primary/30">
      <Navbar />
      
      <div className="container mx-auto px-4 py-24 lg:py-32">
        <Link href={basePath + "/"}>
          <Button variant="ghost" className="mb-8 hover:bg-white/5 hover:text-primary transition-colors">
            <ArrowLeft className="mr-2 h-4 w-4" /> Back to Collection
          </Button>
        </Link>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-24 items-start">
          {/* Image Column */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
            className="relative group"
          >
            <div className="absolute inset-0 bg-primary/20 blur-3xl rounded-full opacity-20 group-hover:opacity-40 transition-opacity duration-700" />
            <div className="relative rounded-2xl overflow-hidden border border-white/10 shadow-2xl shadow-primary/10">
              <img
                src={`${import.meta.env.BASE_URL}${product.imageUrl.replace(/^\//, '')}`}
                alt={product.name}
                className={`w-full h-full object-cover ${product.isSold ? 'grayscale opacity-75' : ''}`}
              />
              {product.isSold && (
                <div className="absolute inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                  <div className="border-4 border-destructive text-destructive font-display font-bold text-5xl px-8 py-4 uppercase tracking-widest transform -rotate-12 shadow-2xl">
                    Sold Out
                  </div>
                </div>
              )}
            </div>
          </motion.div>

          {/* Details Column */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="space-y-8"
          >
            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-primary/80 font-mono text-sm tracking-wider">
                <Sparkles className="w-4 h-4" />
                <span>{product.category === 'design' ? 'WolfMan Design' : `MYSTIC SERIES • NFT #${product.id.toString().padStart(4, '0')}`}</span>
              </div>
              <h1 className="text-5xl lg:text-7xl font-display font-bold text-white leading-tight">
                {product.name}
              </h1>
            </div>

            <div className="flex items-center space-x-4 border-y border-white/10 py-6">
              <div className="flex-1">
                <p className="text-sm text-muted-foreground uppercase tracking-wider mb-1">Current Price</p>
                <p className="text-4xl font-mono text-white flex items-baseline">
                  ${(product.price / 100).toFixed(2)}
                  <span className="text-sm text-muted-foreground ml-2">USD</span>
                </p>
              </div>
              {product.isSold ? (
                <div className="px-4 py-2 bg-destructive/20 border border-destructive/50 rounded-full text-destructive flex items-center">
                  <span className="w-2 h-2 bg-destructive rounded-full mr-2 animate-pulse" />
                  No longer available
                </div>
              ) : (
                <div className="px-4 py-2 bg-green-500/20 border border-green-500/50 rounded-full text-green-400 flex items-center">
                  <span className="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse" />
                  Available for request
                </div>
              )}
            </div>

            <div className="prose prose-invert prose-lg text-muted-foreground font-light leading-relaxed">
              <p>{product.description}</p>
            </div>

            <div className="space-y-4 pt-4">
              <Button
                size="lg"
                className={`w-full h-16 text-lg font-display tracking-wider uppercase transition-all duration-300 relative overflow-hidden ${
                  product.isSold 
                    ? 'bg-muted cursor-not-allowed opacity-50' 
                    : 'bg-primary hover:bg-primary/90 text-primary-foreground shadow-[0_0_20px_rgba(139,92,246,0.4)] hover:shadow-[0_0_40px_rgba(139,92,246,0.6)] hover:-translate-y-1'
                }`}
                disabled={product.isSold}
                onClick={handlePurchase}
              >
                {product.isSold ? (
                  "Sold Out"
                ) : (
                  <>
                    <Zap className="mr-2 h-5 w-5 fill-current" />
                    Request Purchase
                    <ExternalLink className="ml-2 h-4 w-4" />
                  </>
                )}
              </Button>
              
              {!product.isSold && (
                <p className="text-center text-sm text-muted-foreground">
                  Opens a GitHub Issue to request this item. You will need a GitHub account.
                </p>
              )}
            </div>

            {/* Trust Indicators */}
            <div className="grid grid-cols-2 gap-4 pt-8">
              <div className="flex items-center gap-3 p-4 rounded-xl bg-white/5 border border-white/5">
                <ShieldCheck className="w-6 h-6 text-primary" />
                <div>
                  <p className="font-bold text-sm text-white">Verified Authentic</p>
                  <p className="text-xs text-muted-foreground">Original Digital Art</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-4 rounded-xl bg-white/5 border border-white/5">
                <Check className="w-6 h-6 text-primary" />
                <div>
                  <p className="font-bold text-sm text-white">Secure Process</p>
                  <p className="text-xs text-muted-foreground">Via GitHub Issues</p>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
