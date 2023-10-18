import { atom } from "jotai";
import { atomWithStorage } from "jotai/utils";

export const indexAtom = atom(0);
export const roleAtom = atomWithStorage("AccountRole", "null");
