import { atom } from "jotai";
import { atomWithStorage } from "jotai/utils";

export const indexAtom = atom(0);
// test
export const roleAtom = atomWithStorage("AccountRole", "null");
