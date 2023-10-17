import { clsx } from "clsx";
import { ethers } from "ethers";
import { twMerge } from "tailwind-merge";

import type { ClassValue } from "clsx";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(input: Date): string {
  return input.toLocaleDateString("en-US", {
    month: "long",
    day: "numeric",
    year: "numeric",
  });
}

export function absoluteUrl(path: string) {
  return `${process.env.NEXT_PUBLIC_APP_URL}${path}`;
}

export const stringToBytes4 = (str: string) => {
  const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(str));
  console.log("hash", hash.substring(0, 10));

  return hash.substring(0, 10);
};
