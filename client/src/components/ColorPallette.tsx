import { type Color } from "@/types";
import { usePaletteColors } from "@/hooks/usePalleteColors";
import { Palette } from "lucide-react";
import { useState } from "react";
import { cn } from "@/utils";

export const ColorPalette = ({
  selectedColor,
  setSelectedColor,
}: {
  selectedColor: Color;
  setSelectedColor: (color: Color) => void;
}) => {
  const paletteColors = usePaletteColors();
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div
      className={cn(
        "bg-slate-500 fixed mx-auto bottom-1 right-4 flex items-center justify-center shadow-md transition-all duration-800 ease-in-out h-[50px] rounded-full",
        isOpen ? "max-w-[320px] md:max-w-md px-4 shadow-lg" : "w-fit p-3 active:bg-slate-400 hover:bg-slate-400",
      )}
      onClick={isOpen ? undefined : () => setIsOpen(true)}
    >
      <div
        className={cn(
          "items-center h-full w-full overflow-x-auto px-2 transition-opacity duration-800 ease-in-out",
          isOpen ? "flex opacity-100" : "hidden opacity-0",
        )}
      >
        <div className="flex items-center space-x-2 h-full flex-grow">
          {[...paletteColors].map((color, index) => (
            <button
              key={index}
              className={`flex-shrink-0 w-8 h-8 rounded-full ${
                selectedColor === color ? "ring-1 ring-white ring-offset-1" : ""
              }`}
              style={{
                backgroundColor: `rgba(${color.r * 255}, ${color.g * 255}, ${color.b * 255}, ${color.a})`,
              }}
              onClick={() => setSelectedColor(color)}
            />
          ))}
        </div>
      </div>
      <Palette
        className="min-w-8 min-h-8 flex items-center justify-center relative cursor-pointer transition-transform duration-800 ease-in-out"
        onClick={() => setIsOpen((prev) => !prev)}
      />
    </div>
  );
};
