import React from "react";

interface FilterMenuProps {
  statusFilter: "All" | "Active" | "Closed";
  setStatusFilter: (status: "All" | "Active" | "Closed") => void;
}

export const FilterMenu: React.FC<FilterMenuProps> = ({ statusFilter, setStatusFilter }) => {
  return (
    <div className="p-2 md:p-4">
      <div className="mb-2 text-sm font-medium">Status Filter</div>
      <div className="space-y-2">
        <label className="flex items-center">
          <input
            type="radio"
            name="status"
            value="All"
            checked={statusFilter === "All"}
            onChange={() => setStatusFilter("All")}
            className="form-radio text-blue-600"
          />
          <span className="ml-2">All</span>
        </label>
        <label className="flex items-center">
          <input
            type="radio"
            name="status"
            value="Active"
            checked={statusFilter === "Active"}
            onChange={() => setStatusFilter("Active")}
            className="form-radio text-blue-600"
          />
          <span className="ml-2">Active</span>
        </label>
        <label className="flex items-center">
          <input
            type="radio"
            name="status"
            value="Closed"
            checked={statusFilter === "Closed"}
            onChange={() => setStatusFilter("Closed")}
            className="form-radio text-blue-600"
          />
          <span className="ml-2">Closed</span>
        </label>
      </div>
    </div>
  );
};
