%% @doc WHO IS LET IN. PURE.
%%
%% ==========================================================================
%% BEING REFUSED IS NOT THE SAME AS BEING BROKEN
%% ==========================================================================
%%
%% A migrant may arrive at the gates perfectly healthy and still be turned away.
%% That is a decision this island made, and it says nothing whatever about the
%% animal.
%%
%% The first version of the crossing did not have this module and made the error
%% the hard way: because the sender let go irrevocably, a refused creature had
%% nowhere to be, so refusal BECAME destruction, and the design then described
%% that consequence as though it were a property of refusal. It was a transport
%% decision smuggling in a biological one.
%%
%% So the two questions are asked separately, and by different code:
%%
%%   `migrant:unpack/1'  IS THIS A CREATURE AT ALL? Widths, codes, numbers. Fixed,
%%                       technical, and not negotiable: a body and a brain that
%%                       disagree crash the receiving tick. A failure here is not
%%                       an animal and there is nothing to hand back.
%%
%%   `border:consider/2' WILL WE HAVE IT? A judgement, about a creature that is
%%                       fine. A refusal here hands the animal back, alive.
%%
%% ==========================================================================
%% AND THIS IS THE SEAM WHERE POLITICS GOES
%% ==========================================================================
%%
%% ⚠ THE REASON VOCABULARY IS OPEN ON PURPOSE. What an island refuses today is
%% "we are full" and "we are closed". What it may refuse tomorrow is a stranger's
%% kin, an island that never reciprocates, a lineage it has met before, a
%% creature carrying nothing worth having, or whatever else emerges from islands
%% that answer to different people.
%%
%% Nothing downstream may enumerate the reasons. A reason is a word this island
%% chose, it travels on the `creature_turned_away' fact, and a reader shows it
%% rather than interpreting it. The day admission policy is something a world
%% EVOLVES rather than something a person configures, this function is the only
%% thing that has to change.
-module(border).

-export([consider/2, reasons_so_far/0]).

-type verdict() :: admit | {turn_away, atom()}.
-export_type([verdict/0]).

%% @doc Whether this island will take this creature.
%%
%% Takes the unpacked animal and the island's own state, and answers with a word
%% rather than a boolean, because "no" without a reason is the fact that tells a
%% sender nothing and leaves an operator guessing.
-spec consider(map(), map()) -> verdict().
consider(Creature, Island) ->
    weighed([fun closed/2, fun crowded/2], Creature, Island).

weighed([], _C, _I) -> admit;
weighed([Rule | Rest], C, I) -> ruled(Rule(C, I), Rest, C, I).

ruled(admit, Rest, C, I) -> weighed(Rest, C, I);
ruled({turn_away, _Why} = No, _Rest, _C, _I) -> No.

%% ==========================================================================
%% The rules, and there are only two of them yet
%% ==========================================================================

%% AN ISLAND MAY SIMPLY DECLINE. `accepts_migrants' has been on the wire since
%% the first biotope fact and has always been false, so "we are not taking
%% anybody" is a state this system has modelled from the beginning and never
%% acted on.
closed(_Creature, #{border := closed}) -> {turn_away, closed};
closed(_Creature, _Island) -> admit.

%% AND A FULL ISLAND CANNOT TAKE ANOTHER, which is not a policy so much as a
%% fact, but it is still a refusal of a healthy animal rather than a judgement
%% about it. `max_creatures' is the safety valve the world already keeps, and
%% `births_refused' counts the births it has turned down for the same reason:
%% this is the same rule applied at the shore instead of the womb.
crowded(_Creature, #{population := Pop, max_creatures := Max}) when Pop >= Max ->
    {turn_away, full};
crowded(_Creature, _Island) ->
    admit.

%% @doc Every reason this island can currently give, for a page that wants to
%% say what happened without inventing words.
%%
%% ⚠ NAMED `reasons_so_far' RATHER THAN `reasons', because a closed list here
%% would be a promise that admission policy is finished, and it is the part of
%% this module most likely to grow. Nothing may branch on this being complete.
-spec reasons_so_far() -> [atom()].
reasons_so_far() -> [closed, full].
