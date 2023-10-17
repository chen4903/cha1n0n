"use client";

import { SingerCard } from "./singer-card";

export function SingerTab() {
  return (
    <div className="grid grid-cols-2  gap-6">
      <SingerCard />
      <SingerCard />
      <SingerCard />
    </div>
  );
}
