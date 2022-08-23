# Expandable Dynamic Sized Table View Cell

A couple of examples on how to create table view cells that can change its size without having the parent table view reload it.

Check out [Expandable and dynamic sized Table View Cell](https://medium.com/@thomsmed/expandable-and-dynamic-sized-table-view-cell-a870e4320a7d) for a writeup @ Medium.

## AccordionTableViewCell

Simple example of an expandable table view cell (AccordionTableViewCell).
The UITableViewCell gets a hold on its parent UITableView when it needs to update its layout.
It then groups the updates (with or without animation) inside a call to UITableView.performBatchUpdates() to update the cell's layout.

## DetailsTableViewCell

Simple example of an expandable table view cell (DetailsTableViewCell), that expands to show details about a person.
When the UITableViewCell is selected, the owning UITableViewController changes its "expanded" state.
And does this (with or without animation) inside a call to UITableView.performBatchUpdates() to update the cell's layout.
