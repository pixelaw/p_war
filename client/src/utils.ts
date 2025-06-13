import { type WorldsRegistry, ZOOM_DEFAULT } from "@pixelaw/core";

export const DEFAULT_WORLD = "local";

export const clearDomChildren = (element: HTMLElement) => {
  while (element.firstChild) {
    element.removeChild(element.firstChild);
  }
};
export const hexRGBtoNumber = (color: string) => {
  return Number.parseInt(`${color.replace("#", "")}FF`, 16);
};

export const numberToHexRGB = (num: number) => {
  const hex = (num >>> 8).toString(16).padStart(6, "0");
  return `#${hex}`.toUpperCase();
};

export function getWorldForUrl(
  config: WorldsRegistry,
  url: string,
  defaultWorld: string,
): string {
  for (const worldName in config) {
    // @ts-ignore TODO
    if (config[worldName].config.serverUrl.startsWith(url)) {
      return worldName;
    }
  }

  return defaultWorld;
}

export function getCoreDefaultsFromUrl() {
  const queryParams = new URLSearchParams(window.location.search);
  const app = queryParams.get("app") || "";
  const color = Number.parseInt(queryParams.get("color") || "0", 10);
  const center = queryParams.get("center")?.split(",").map(Number) as
    | [number, number]
    | undefined;
  const zoom = Number.parseFloat(queryParams.get("zoom") || "7");

  return {
    app,
    color: Number.isNaN(color) ? 0 : color,
    center: center && center.length === 2 ? center : [12, 12],
    zoom: Number.isNaN(zoom) ? ZOOM_DEFAULT : zoom,
  };
}
