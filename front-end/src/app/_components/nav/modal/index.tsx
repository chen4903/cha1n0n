import clsx from "clsx";
import React from "react";
import Lottie from "lottie-react";
import { Divider } from "~/app/_components/divider";
import arrowIcon from "public/icons/static/arrow.json";

import { usePathname } from "next/navigation";
import { MarketLenth } from "./marketLength";

export function Modal() {
  const pathname = usePathname();

  const arrowRef = React.useRef<any>();
  return (
    <div className="hidden flex-col gap-1.5 lg:flex">
      <Divider className="mb-4" />
      <MarketLenth />
    </div>
  );
}
