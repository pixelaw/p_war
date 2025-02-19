export const DEFAULT_WORLD = "tunnel-populated"

export const clearDomChildren = (element: HTMLElement) => {
    while (element.firstChild) {
        element.removeChild(element.firstChild);
    }
};
export const hexRGBtoNumber = (color: string) => {
    return Number.parseInt(`${color.replace("#", "")}FF`, 16)
}

export const numberToHexRGB = (num: number) => {
    const hex = (num >>> 8).toString(16).padStart(6, '0');
    return `#${hex}`.toUpperCase();
};


export function getCoreDefaultsFromUrl() {
    const queryParams = new URLSearchParams(window.location.search);
    const app = queryParams.get("app") || "";
    const color = parseInt(queryParams.get("color") || "0", 10);
    const center = queryParams.get("center")?.split(",").map(Number) as [number, number] | undefined;
    const zoom = parseInt(queryParams.get("zoom") || "7000", 10);

    return {
        app,
        color: isNaN(color) ? 0 : color,
        center: center && center.length === 2 ? center : [0, 0],
        zoom: isNaN(zoom) ? 0 : zoom,
    };
}