import { Switch, Route } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import Home from "@/pages/Home";
import ProductDetail from "@/pages/ProductDetail";
import About from "@/pages/About";
import NotFound from "@/pages/not-found";

// Get the base path from Vite's BASE_URL environment variable
const basePath = import.meta.env.BASE_URL.replace(/\/$/, '');

function Router() {
  return (
    <Switch>
      <Route path={basePath + "/"} component={Home} />
      <Route path={basePath + "/product/:id"} component={ProductDetail} />
      <Route path={basePath + "/about"} component={About} />
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Router />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
// claim link added
// claim link added
