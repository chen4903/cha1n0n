import { atom } from "jotai";
import { atomWithStorage } from "jotai/utils";

export const isVisibleAtom = atom(false);
export const roleAtom = atomWithStorage("AccountRole", "null");
