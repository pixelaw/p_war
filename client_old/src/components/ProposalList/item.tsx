import { NEEDED_YES_VOTING_POWER } from "@/constants";
import { Proposal } from "@/libs/dojo/typescript/models.gen";
import { cn, createProposalTitle, formatTimeRemaining, formatWalletAddressWithEmoji, uint32ToHex } from "@/utils";
import React, { useEffect, useMemo, useState } from "react";
import { ActivateProposalButton } from "../ActivateButton";
import { VoteButton } from "../VoteButton";

interface VotePercentageProps {
  yes_voting_power: number;
  no_voting_power: number;
}

export const VotePercentage: React.FC<VotePercentageProps> = ({ yes_voting_power, no_voting_power }) => {
  const total = yes_voting_power + no_voting_power;
  const yesPercentage = total > 0 ? (yes_voting_power / total) * 100 : 0;
  const noPercentage = total > 0 ? (no_voting_power / total) * 100 : 0;

  return (
    <div className="w-full max-w-[70%]">
      <div className="relative mb-1 flex h-2 rounded-full bg-gray-700 w-full">
        <div className="h-full rounded-l-full bg-green-500" style={{ width: `${yesPercentage}%` }} />
        <div className="h-full rounded-r-full bg-red-500" style={{ width: `${noPercentage}%` }} />
      </div>
      <div className="flex justify-between text-xs text-gray-300 px-1">
        <p>For {yes_voting_power}</p>
        <p>Against {no_voting_power}</p>
      </div>
    </div>
  );
};

interface ProposalItemProps {
  proposal: Proposal;
}

export const ProposalItem: React.FC<ProposalItemProps> = ({ proposal }) => {
  // State
  const [proposalStatus, setProposalStatus] = useState("");
  const hexColor = uint32ToHex(proposal.target_args_1);
  const title = createProposalTitle(proposal.proposal_type, proposal.target_args_1, proposal.target_args_2);
  const canActivateProposal = useMemo(
    () => proposal.yes_voting_power >= NEEDED_YES_VOTING_POWER && proposal.yes_voting_power > proposal.no_voting_power,
    [proposal],
  );

  useEffect(() => {
    if (proposalStatus === "closed") return;

    const interval = setInterval(() => {
      const current = Math.floor(Date.now() / 1000);

      if (current < proposal.start) {
        setProposalStatus(`starts in ${formatTimeRemaining(proposal.start - current)}`);
      } else if (current > proposal.start && current < proposal.end) {
        setProposalStatus(`ends in ${formatTimeRemaining(proposal.end - current)}`);
      } else {
        setProposalStatus("closed");
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [proposal, proposalStatus]);

  return (
    <div
      className={cn(
        "relative p-3 rounded-md border transition-colors duration-300",
        proposalStatus === "closed"
          ? "bg-gray-600 border-gray-700"
          : "bg-gray-800 border-gray-700 hover:border-gray-600",
      )}
    >
      <div className="mb-1 flex items-center justify-between">
        <div className={`flex items-center text-sm font-bold ${getTextColor(proposalStatus, proposal)}`}>
          {title}
          {hexColor && <div className="ml-2 size-6 rounded-md" style={{ backgroundColor: hexColor }} />}
        </div>
        <div className={`rounded-md ml-[7px] px-2 py-1 text-xs text-white ${getStatusColor(proposalStatus)}`}>
          {proposalStatus}
        </div>
      </div>
      <div className="mb-2 text-xs text-gray-400">
        proposed by {formatWalletAddressWithEmoji("0x" + proposal.author.toString(16))}
      </div>

      <VotePercentage yes_voting_power={proposal.yes_voting_power} no_voting_power={proposal.no_voting_power} />

      {proposalStatus === "" ? (
        "..."
      ) : proposal.is_activated ? (
        <button
          className={cn(
            "absolute bottom-4 right-4 rounded-md px-2 md:px-4 py-2 text-xs md:text-sm transition duration-300 cursor-not-allowed bg-gray-500 text-green-300",
          )}
          disabled={true}
        >
          Applied
        </button>
      ) : proposalStatus === "closed" ? (
        canActivateProposal ? (
          <ActivateProposalButton proposal={proposal} />
        ) : (
          <button
            className={cn(
              "absolute bottom-4 right-4 rounded-md px-2 md:px-4 py-2 text-xs md:text-sm transition duration-300 cursor-not-allowed bg-gray-500 text-red-300",
            )}
            disabled={true}
          >
            Denied
          </button>
        )
      ) : (
        <VoteButton proposal={proposal} title={title} />
      )}
    </div>
  );
};

const getStatusColor = (status: string) => {
  if (status.startsWith("ends in")) {
    return "bg-green-500";
  } else if (status === "closed") {
    return "bg-purple-500";
  } else {
    return "bg-gray-500";
  }
};

// doesn't work correctly...
const getTextColor = (proposalStatus: string, proposal: Proposal) => {
  if (proposalStatus === "closed" && proposal.yes_voting_power > proposal.no_voting_power) {
    return "text-green-300";
  } else if (proposalStatus === "closed" && proposal.yes_voting_power <= proposal.no_voting_power) {
    return "text-red-300";
  } else {
    return "text-white";
  }
};
