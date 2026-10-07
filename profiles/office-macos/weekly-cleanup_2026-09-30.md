# Weekly cleanup 2026-09-30

## start

1. start: 2026-09-30 10:08

## reminder

1. this meeting is about cleanup and system admin
2. the more we cleanup here, the easier it is to focus on the substance of
   issues all the rest of the time

## make a short list off the below long list

### backlog review

1. look for tickets assigned to MS
   1. some teams want to use this as their communication mechanism
   2. use shared query
      1. folder: "Team Valkyrie"
      2. query name: assigned-to-michael_not-done-removed-rejected
2. Update tags
   1. find untagged items
   2. update items last touched > 2 months ago
   3. tag reference:
      1. keep: `wc-k-MM`
      2. Add worktype tags
         1. `w-f` for `work type: feature`
         2. `w-t` for `work type: tech`
      3. Misc tags
         1. `wt-gav` for when a ticket should be dragged until gav prioritises
            it
            1. no need for `wc-k-MM` tag in a `wt-gav` ticket
               1. this tag specifically exists so that we can remove these
                  tickets from the cycle of periodic review

### parked column items review

1. look at board "parked" col items
   1. can any be removed?

### Api endpoint teardown candidate search

1. [blocker] row metadata

### roadmap review

1. cross reference item titles and ticket numbers against each other
2. cleanup small reminder items

### tech quality list review

1. cross reference item titles and ticket numbers against each other

### branch review

1. [drag] any value to keeping release branches?
   1. e.g. consider removing older than 10 releases old
2. bonus item
   1. PR cleanup?

### tickets dir review

1. review the tickets dir in `this` docs repo
2. archive where done
3. consolidate where required
4. identify any actionable items that are not on
   1. roadmap
   2. tech qual list
   3. backlog

### review of dependencies

1. review dependency list for each of our projects including hub
   1. what can we remove?
      1. unused
      2. deps
      3. dependencies that are used but could be phased out
         1. moment js
         2. lodash
2. dotnet10 `dotnet list package --include-transitive`
3. `dotnet list package --vulnerable --include-transitive`
4. dependency graph exists in github
   1. github.com/vald-green/vald.api.humantrak.v2/network/dependencies?q=

### review valkyrie-todo

1. we place `[valkyrie-todo]` around the repo for followup tasks
2. search the repo for some and either
   1. delete if complete/superseded
   2. add to roadmap/tech-quality list
3. next steps
   1. brainstorm
      1. try resolving all existing todos
         1. maybe that'll just work in the time available
      2. try resolving _some_ todos per week
      3. use pickaxe to detect new instances
         1. leaving old ones ignored
      4. construct a list of known ignoreables

### 1password

1. vault `Engineering - Valkyrie Shared Credentials`
2. check your personal "Employee" vault
   1. if there is something stale you can right click and archive
      1. still retrievable if it matters someday

### continuous improvement section in look-back

1. we've collected a lot of notes in that list
   1. is all of it still relevant
   2. can we prune anything?
   3. anything that should be something else?
      1. tech qual
      2. guideline
      3. roadmap
      4. docs
         1. docs on trunk based for example
      5. etc

### Cleanup testing data

1. purge record created by Valkyrie-test
   1. DB
   2. Blob storage
2. invoke tenant deleted handler

## shortlist

1. tech quality list review [5min]

## end

1. end: 10:58
