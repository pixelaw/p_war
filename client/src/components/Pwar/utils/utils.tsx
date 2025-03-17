import { emojiAvatarForAddress } from "./EmojiAvatar";

export const uint32ToHex = (uint32: number) => {
    const color = uint32 >>> 8;
    return "#" + color.toString(16).padStart(6, "0");
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
      return avatar.emoji + " " + `${address.slice(0, 4)}...${address.slice(-4)}`;
    }
    return avatar.emoji + " " + address;
};