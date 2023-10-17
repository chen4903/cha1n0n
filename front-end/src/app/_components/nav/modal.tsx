import clsx from "clsx";
import React from "react";
import Lottie from "lottie-react";
import { Divider } from "../divider";
import arrowIcon from "public/icons/static/arrow.json";

import { usePathname } from "next/navigation";

export function Modal() {
  const pathname = usePathname();

  const arrowRef = React.useRef<any>();
  return (
    <div className="hidden flex-col gap-1.5 lg:flex">
      <Divider className="mb-4" />
      <button
        onMouseEnter={() => arrowRef.current?.play()}
        onMouseLeave={() => arrowRef.current?.stop()}
        className={clsx(
          "text-foreground hover:text-primary flex items-center gap-2 rounded-lg px-2.5 py-2 duration-300  hover:bg-neutral-800",
        )}
      >
        <Lottie
          lottieRef={arrowRef}
          animationData={arrowIcon}
          style={{ width: 20, height: 20 }}
          autoplay={false}
          loop={false}
        />
        <span className="text-sm capitalize">quary album</span>
      </button>
      <button
        onMouseEnter={() => arrowRef.current?.play()}
        onMouseLeave={() => arrowRef.current?.stop()}
        className={clsx(
          "text-foreground hover:text-primary flex items-center gap-2 rounded-lg px-2.5 py-2 duration-300  hover:bg-neutral-800",
        )}
      >
        <Lottie
          lottieRef={arrowRef}
          animationData={arrowIcon}
          style={{ width: 20, height: 20 }}
          autoplay={false}
          loop={false}
        />
        <span className="text-sm capitalize">quary singer</span>
      </button>
    </div>
  );
}
