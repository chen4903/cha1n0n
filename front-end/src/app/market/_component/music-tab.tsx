"use client";

import { MusicCard } from "./music-card";

export function MusicTab() {
  return (
    <div className="grid grid-cols-1 pt-6 gap-6">
      <MusicCard />
      <MusicCard />
      <MusicCard />
    </div>
  );
}
