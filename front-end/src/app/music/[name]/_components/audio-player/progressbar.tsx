"use client";

import { Progress } from "@nextui-org/react";

type ProgressBarProps = {
  progress: number;
  onChange: (value: number) => void;
  leftLabel?: string;
  rightLabel?: string;
  name: string;
};

const ProgressBar = ({
  progress,
  onChange,
  leftLabel,
  rightLabel,
  name,
}: ProgressBarProps) => {
  return (
    <div className="flex h-full flex-col justify-end gap-6">
      <div className="flex flex-col">
        <Progress
          aria-label={name}
          classNames={{
            indicator: "bg-default-800 dark:bg-white",
            track: "bg-default-500/30",
          }}
          color="default"
          size="sm"
          value={progress}
          minValue={0}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            onChange(parseInt(event?.target.value));
          }}
        />
        <div className="mt-2 flex w-full flex-row justify-between  text-primary/30">
          <span className="text-xs">1{leftLabel}</span>
          <span className="text-xs">2{rightLabel}</span>
        </div>
      </div>
    </div>
  );
};

export default ProgressBar;
