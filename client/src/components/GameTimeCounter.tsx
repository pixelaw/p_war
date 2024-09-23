import { useState, useEffect } from "react";

export const GameTimeCounter = ({ endTime }: { endTime?: number }) => {
  const [timeLeft, setTimeLeft] = useState("");

  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      const gameEndTime = new Date(Number(endTime) * 1000);
      const difference = gameEndTime.getTime() - now.getTime();

      if (difference > 0) {
        const days = Math.floor(difference / (1000 * 60 * 60 * 24));
        const hours = Math.floor((difference / (1000 * 60 * 60)) % 24);
        const minutes = Math.floor((difference / 1000 / 60) % 60);
        const seconds = Math.floor((difference / 1000) % 60);

        setTimeLeft(
          `${days.toString().padStart(2, "0")}:${hours.toString().padStart(2, "0")}:${minutes
            .toString()
            .padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`,
        );
      } else {
        setTimeLeft("00:00:00:00");
        clearInterval(timer);
      }
    }, 1000);

    return () => clearInterval(timer);
  }, [endTime]);

  return (
    <div className="bg-header-primary flex items-center px-4 relative">
      <div className="font-roboto-mono text-xl font-bold text-yellow-500 absolute left-1/2 transform -translate-x-1/2 drop-shadow-lg">
        {timeLeft}
      </div>
    </div>
  );
};
