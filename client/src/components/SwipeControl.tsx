import { detectMobile } from "@/utils/devices";
import { useEffect, useLayoutEffect } from "react";
import { useSwipeable } from "react-swipeable";

const SwipeControl = ({ children }: { children: React.ReactNode }) => {
  const isMobile = detectMobile();

  useLayoutEffect(() => {
    // add dummy entry to browser history
    window.history.pushState(null, "", window.location.pathname);

    // add listener for popstate event
    const handlePopState = (e: PopStateEvent) => {
      e.stopImmediatePropagation();
      // prevent browser back motion
      window.history.pushState(null, "", window.location.pathname);
    };

    window.addEventListener("popstate", handlePopState);

    // remove listener when component unmounts
    return () => {
      window.removeEventListener("popstate", handlePopState);
    };
  }, []);

  useEffect(() => {
    if (!isMobile) return;
    // NOTE: improve mobile scroll experience
    window.addEventListener(
      "wheel",
      (e) => {
        e.preventDefault();
      },
      { passive: false },
    );
  }, [isMobile]);

  const handlers = useSwipeable({
    preventScrollOnSwipe: true,
    trackMouse: true,
  });

  return <div {...handlers}>{children}</div>;
};

export default SwipeControl;
