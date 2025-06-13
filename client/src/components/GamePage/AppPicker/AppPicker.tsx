import App from "@/components/GamePage/App/App.tsx";
import { usePixelawProvider } from "@pixelaw/react";
import styles from "./AppPicker.module.css";

export interface AppPickerProps {
  setSelectedApp: (appName: string) => void;
  selectedApp: string;
  onClose: () => void;
}

const AppPicker: React.FC<AppPickerProps> = ({
  setSelectedApp,
  selectedApp,
  onClose,
}) => {
  const {
    pixelawCore: { appStore },
  } = usePixelawProvider();

  if (!appStore) return null;
  const allApps = appStore.getAll();

  return (
    <div className={"pickerPanel"}>
      {allApps
        .filter((app) => app.name !== "player" && app.name !== "paint")
        .map((app) => (
          // biome-ignore lint/a11y/useKeyWithClickEvents: TODO keyboard support later
          <div
            key={app.name}
            onClick={() => {
              setSelectedApp(app.name);
              onClose();
            }}
            className={app.name === selectedApp ? styles.selected : ""}
          >
            <App icon={app.icon} name={app.name} />
          </div>
        ))}
    </div>
  );
};

export default AppPicker;
