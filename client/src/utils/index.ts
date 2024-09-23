import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { type Color } from "@/types";
import { getComponentValue } from "@dojoengine/recs";
import { App } from "@/types";
import { shortString } from "starknet";
import { emojiAvatarForAddress } from "@/components/Avatar/emojiAvatarForAddress";

export const cn = (...inputs: ClassValue[]) => {
  return twMerge(clsx(inputs));
};

export const truncateAddress = (address: string) => {
  const truncateRegex = /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
  const match = address.match(truncateRegex);
  if (!match || match.length < 3) return address;
  const part1 = match[1] || "";
  const part2 = match[2] || "";
  return `0x${part1}…${part2}`;
};

export const formatDate = (date: Date | string): string => {
  const dateObj = typeof date === "string" ? new Date(date) : date;
  return `${dateObj.getFullYear()}/${(dateObj.getMonth() + 1).toString().padStart(2, "0")}/${dateObj
    .getDate()
    .toString()
    .padStart(2, "0")}:${dateObj.getHours().toString().padStart(2, "0")}:${dateObj
    .getMinutes()
    .toString()
    .padStart(2, "0")}`;
};

export const rgbaToUint32 = (color: Color): number => {
  const r = Math.round(color.r * 255);
  const g = Math.round(color.g * 255);
  const b = Math.round(color.b * 255);
  const a = Math.round(color.a * 255);
  return ((r << 24) | (g << 16) | (b << 8) | a) >>> 0; // Convert to unsigned 32-bit integer
};

export const uint32ToRgba = (uint32: number): Color => {
  const r = ((uint32 >>> 24) & 0xff) / 255;
  const g = ((uint32 >>> 16) & 0xff) / 255;
  const b = ((uint32 >>> 8) & 0xff) / 255;
  const a = (uint32 & 0xff) / 255;
  return { r, g, b, a };
};

// Converts the numeric RGBA to a normal hex color
// @dev this removes the Alpha channel.
// TODO: Eventually convert to rgb(255 0 153 / 80%)
// ref: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
export const uint32ToHex = (uint32: number) => {
  const color = uint32 >>> 8;
  return "#" + color.toString(16).padStart(6, "0");
};

export const rgbaToHex = (rgba: Color) => {
  const { r, g, b, a } = rgba;
  return `rgba(${r * 255}, ${g * 255}, ${b * 255}, ${a})`;
};

export const handleTransactionError = (error: unknown) => {
  let errorMessage = "An unexpected error occurred. Please try again.";

  if (error instanceof Error) {
    const result = error.message.match(/\('([^']+)'\)/)?.[1];
    if (result) {
      errorMessage = result;
    }
  }

  return errorMessage;
};

export const felt252ToString = (felt252: string | number | bigint) => {
  if (typeof felt252 === "bigint" || typeof felt252 === "object") {
    felt252 = `0x${felt252.toString(16)}`;
  }
  if (felt252 === "0x0" || felt252 === "0") return "";
  if (typeof felt252 === "string") {
    try {
      return shortString.decodeShortString(felt252);
    } catch (e) {
      console.error("Error decoding short string:", e);
      return felt252;
    }
  }
  return felt252.toString();
};

export const felt252ToUnicode = (felt252: string | number) => {
  const string = felt252ToString(felt252);
  if (string.includes("U+")) {
    const text = string.replace("U+", "");
    const codePoint = Number.parseInt(text, 16);
    return String.fromCodePoint(codePoint);
  }
  return string;
};

export const fromComponent = (appComponent: ReturnType<typeof getComponentValue>): App | undefined => {
  if (!appComponent) return undefined;

  return {
    name: shortString.decodeShortString(appComponent.name),
    icon: felt252ToUnicode(appComponent.icon),
    action: shortString.decodeShortString(appComponent.action),
    system: appComponent.system,
    manifest: appComponent.manifest,
  };
};

export const formatTimeRemaining = (remainingSeconds: number): string => {
  const days = Math.floor(remainingSeconds / 86400);
  remainingSeconds %= 86400;
  const hours = Math.floor(remainingSeconds / 3600);
  remainingSeconds %= 3600;
  const minutes = Math.floor(remainingSeconds / 60);
  const seconds = remainingSeconds % 60;

  let formattedTime = "";
  if (days > 0) {
    formattedTime += `${days}d`;
  }
  if (hours > 0) {
    formattedTime += `${hours}h`;
  }
  if (minutes > 0) {
    formattedTime += `${minutes}m`;
  }
  if (seconds > 0) {
    formattedTime += `${seconds}s`;
  }

  return formattedTime || "0s";
};

export const formatTimeRemainingForTitle = (remainingSeconds: number): string => {
  const days = Math.floor(remainingSeconds / 86400);
  remainingSeconds %= 86400;
  const hours = Math.floor(remainingSeconds / 3600);
  remainingSeconds %= 3600;
  const minutes = Math.floor(remainingSeconds / 60);
  const seconds = remainingSeconds % 60;

  let formattedTime = "";
  if (days > 0) {
    formattedTime += `${days}D`;
  }
  if (hours > 0) {
    formattedTime += ` ${hours}H`;
  }
  if (minutes > 0) {
    formattedTime += ` ${minutes}M`;
  }
  if (seconds > 0) {
    formattedTime += ` ${seconds}S`;
  }

  return formattedTime || "0S";
};

export const formatWalletAddressWithEmoji = (address: string) => {
  const avatar = emojiAvatarForAddress(address);
  if (address.length > 10) {
    return avatar.emoji + `${address.slice(0, 4)}...${address.slice(-4)}`;
  }
  return avatar.emoji + address;
};
