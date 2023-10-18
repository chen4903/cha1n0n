"use client";

import React from "react";
import { AlbumCard } from "./_components/album";
import { AnimateEnter } from "~/app/_components/animate-enter";

export default function MusicPage() {
  const [init, setInit] = React.useState(false);

  React.useEffect(() => {
    setInit(true);
  }, []);
  return (
    <>
      {init ? (
        <AnimateEnter className="lg:w-4/5 py-12 pl-2">
          <section className="grid w-fit grid-cols-2 gap-6 ">
            <AlbumCard />
            <AlbumCard />
            <AlbumCard />
          </section>
        </AnimateEnter>
      ) : null}
    </>
  );
}
