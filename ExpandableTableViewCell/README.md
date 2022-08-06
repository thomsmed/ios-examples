# Expandable Dynamic Sized Table View Cell

A couple of examples on how to create table view cells that can change its size without having the parent table view reload it.

## AccordionTableViewCell

Simple example of an expandable table view cell (AccordionTableViewCell).
The UITableViewCell gets a hold on its parent UITableView when it needs to update its layout.
It then groups the updates (with or without animation) between calls to UITableView.beginUpdates() and UITableView.endUpdates() to update the cell's layout.

## DetailsTableViewCell

Simple example of an expandable table view cell (DetailsTableViewCell), that expands to show details about a person.
When the UITableViewCell is selected, the owning UITableViewController changes its "expanded" state.
And does this (with or without animation) between calls to UITableView.beginUpdates() and UITableView.endUpdates() to update the cell's layout.
