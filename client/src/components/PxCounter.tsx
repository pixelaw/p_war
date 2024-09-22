import { usePixelRecoveryRate } from "@/hooks/usePixelRecoveryRate";
import { usePlayer } from "@/hooks/usePlayer";
import { useEffect, useState } from "react";

const PxCounter = () => {
  const { player } = usePlayer();
  const { pixelRecoveryRate } = usePixelRecoveryRate();

  const playerPx = player?.current_px ?? 10; // Default to 10 if player is not loaded
  const maxPx = player?.max_px ?? 10; // Default to 10 if player is not loaded
  const recoveryRate = pixelRecoveryRate?.rate ?? 0;
  const playerLastDate = player?.last_date ?? 0;

  const [currentPx, setCurrentPx] = useState(playerPx);
  const [lastDate, setLastDate] = useState(playerLastDate);
  const [pxChange, setPxChange] = useState(0);

  useEffect(() => {
    if (lastDate === playerLastDate) return;
    const currentSeconds = Math.floor(Date.now() / 1_000);
    const pxRecovered = Math.floor((currentSeconds - playerLastDate) / recoveryRate);
    const newPx = playerPx + pxRecovered > maxPx ? maxPx : playerPx + pxRecovered;
    setPxChange(newPx - currentPx);
    setCurrentPx(newPx);
    setLastDate(playerLastDate);
  }, [playerLastDate, playerPx, lastDate, recoveryRate, maxPx, currentPx]);

  useEffect(() => {
    if (!recoveryRate || maxPx === currentPx) return;
    const interval = setInterval(() => {
      setCurrentPx((prevCurrentPx) => {
        const newPx = prevCurrentPx === maxPx ? maxPx : prevCurrentPx + 1;
        setPxChange(1);
        return newPx;
      });
    }, recoveryRate * 1_000);

    return () => clearInterval(interval);
  }, [recoveryRate, currentPx, maxPx]);

  useEffect(() => {
    if (pxChange !== 0) {
      const timeout = setTimeout(() => setPxChange(0), 1000);
      return () => clearTimeout(timeout);
    }
  }, [pxChange]);

  return (
    <div
      className={`flex items-center gap-2 bg-white bg-opacity-10 rounded-xl px-4 py-2 font-mono text-sm text-white tracking-wider border border-yellow-400 shadow-[0_0_10px_rgba(255,215,0,0.5)] ${
        currentPx === 0
          ? "bg-red-500 bg-opacity-10 text-red-500 border-red-500 shadow-[0_0_10px_rgba(255,0,0,0.5)]"
          : ""
      }`}
    >
      {currentPx}/{maxPx} PX
      {pxChange !== 0 && (
        <div className="absolute top-5 left-[70%] -translate-x-[10%] bg-black bg-opacity-80 text-white px-2 py-1 rounded font-mono text-sm font-bold animate-[fadeInOut_1s_ease-in-out]">
          {pxChange > 0 ? `+${pxChange}` : pxChange}
        </div>
      )}
    </div>
  );
};

export default PxCounter;
