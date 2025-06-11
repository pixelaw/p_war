import React from "react";

interface Proposal {
  id: number;
  title: string;
  author: string;
  yesVotes: number;
  noVotes: number;
  isActive: boolean;
}

interface ProposalItemProps {
  proposal: Proposal;
}

export const ProposalItem: React.FC<ProposalItemProps> = ({ proposal }) => {
  const totalVotes = proposal.yesVotes + proposal.noVotes;
  const yesPercentage =
    totalVotes > 0 ? (proposal.yesVotes / totalVotes) * 100 : 0;
  const noPercentage =
    totalVotes > 0 ? (proposal.noVotes / totalVotes) * 100 : 0;

  return (
    <div className="p-4 bg-gray-800 rounded-lg border border-gray-700">
      <div className="flex justify-between items-center mb-2">
        <h3 className="text-white font-bold">{proposal.title}</h3>
        <span className="text-gray-400 text-sm">by {proposal.author}</span>
      </div>

      {/* Vote Progress Bar */}
      <div className="w-full mb-4">
        <div className="relative h-2 rounded-full bg-gray-700">
          <div
            className="absolute h-full rounded-l-full bg-green-500"
            style={{ width: `${yesPercentage}%` }}
          />
          <div
            className="absolute h-full rounded-r-full bg-red-500"
            style={{ width: `${noPercentage}%`, left: `${yesPercentage}%` }}
          />
        </div>
        <div className="flex justify-between text-sm mt-1">
          <span className="text-green-500">Yes: {proposal.yesVotes}</span>
          <span className="text-red-500">No: {proposal.noVotes}</span>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex gap-2 justify-end">
        <button
          onClick={() => console.log("Vote Yes for", proposal.id)}
          className="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-500"
        >
          Vote Yes
        </button>
        <button
          onClick={() => console.log("Vote No for", proposal.id)}
          className="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-500"
        >
          Vote No
        </button>
      </div>
    </div>
  );
};
