import React from "react";
import { env } from "~/env.mjs";
import abi from "~/config/abi.json";
import { stringToBytes4 } from "~/utils";
import { useAccount, useContractWrite } from "wagmi";
import { usePrepareContractWrite, useWaitForTransaction } from "wagmi";

//   订阅歌手
interface DescribeSingerProps {
  singer: string;
  time: string;
  onSetSongSuccess?: () => void;
}

interface SongState {
  address: `0x${string}` | undefined;
  describeSinger: (() => void) | undefined;
  describeSingerLoading: boolean;
  preparedescribeSingerbeError: boolean;
  describeSingerError: boolean;
}

export const useDescribeSinger = ({
  singer,
  time,
  onSetSongSuccess,
}: DescribeSingerProps) => {
  const { address } = useAccount();

  const [state, setState] = React.useState<SongState>({
    address: undefined,
    describeSinger: undefined,
    describeSingerLoading: false,
    preparedescribeSingerbeError: false,
    describeSingerError: false,
  });

  const { config, isError: preparedescribeSingerbeError } =
    usePrepareContractWrite({
      address: env.NEXT_PUBLIC_CONTRACT_ADDRESS as `0x${string}`,
      chainId: parseInt(env.NEXT_PUBLIC_CHAIN_ID ?? "5"),
      abi,
      functionName: "describe",
      args: ["0.1", singer, "0x00000000", time, address],
    });

  const {
    data,
    write: describeSinger,
    isLoading: describeSingerLoading,
    isError: describeSingerError,
  } = useContractWrite(config);

  const { isLoading: txLoading } = useWaitForTransaction({
    hash: data?.hash,
    onSuccess: () => {
      if (onSetSongSuccess) {
        onSetSongSuccess();
      }
    },
  });

  React.useEffect(() => {
    setState({
      address,
      describeSinger,
      describeSingerLoading: describeSingerLoading || txLoading,
      preparedescribeSingerbeError,
      describeSingerError,
    });
  }, [
    address,
    describeSinger,
    describeSingerLoading,
    preparedescribeSingerbeError,
    describeSingerError,
    txLoading,
  ]);

  return state;
};
