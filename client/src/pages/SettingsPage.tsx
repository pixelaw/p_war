// import { clearIdb } from "@/webtools/utils.ts"
import styles from "./SettingsPage.module.css";

const SettingsPage = () => {
  const handleClearIdb = async () => {
    // TODO hookup webcore
    // await clearIdb()
  };
  const handleResetUrl = () => {
    const url = window.location.origin; // + window.location.pathname;
    window.location.href = url;
  };
  return (
    <div className={styles.inner}>
      <h1>Settings</h1>
      <ul className={styles.settingsList}>
        <li className={styles.settingItem}>
          <span className={styles.settingLabel}>Clear IndexedDB</span>
          <button type={"button"} onClick={handleClearIdb}>
            Clear
          </button>
        </li>
        <li className={styles.settingItem}>
          <span className={styles.settingLabel}>Example Setting</span>
          <input type="text" className={styles.settingInput} />
        </li>
        <li className={styles.settingItem}>
          <button type={"button"} onClick={handleResetUrl}>
            Reset URL
          </button>
        </li>
      </ul>
    </div>
  );
};

export default SettingsPage;
