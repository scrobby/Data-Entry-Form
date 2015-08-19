# DataEntryController
A simple way of creating forms designed for data entry and presenting them to the user.

## DataEntryForm
This class is designed to be subclassed to create custom data entry forms.

The DataEntrySetup automatically adds “Done” and “Cancel” buttons to the bottom of the DataEntryForm, in a style that mimics that of a UIAlertController.

Any object subclassing DataEntryForm should **never** add anything directly to “self”. Any subviews should be placed on the contentView. This is a view which is translucent white by default, but can be changed to any colour/transparency.


#### To-Do
- Currently it is not very easy to create custom subclasses without altering the DataEntrySetup superclass itself. (It is possible; it just requires jumping through a few hoops.)
- It is not possible to remove the “Cancel” button, or even turn it into a “Back” button.
- Though there is a *title* property, it currently serves no purpose. The DataEntryForm should add a title to the top, similar to a UIAlertController Alert.


### DataEntryFormAmount
This is a numerical entry that presents the user with a calculator-style data entry form in which they can enter any number. This automatically adds a currency symbol and decimal places, and allows the user to make the value negative or positive.


#### To-Do
- Need to add an image for the “Delete” button so it doesn’t look so ugly.
- Currently isn’t easy to disable currency.
- Currently isn’t easy to allow/disallow negative values
- Currently isn’t possible to alter the position of the decimal place (or to allow non-decimal values)


### DataEntryFormText
This is a very simple subclass that makes it easy to present the user with a way of entering text. There is a placeholder value, allowing the user to be prompted about what they should enter in the field.


### DataEntryFormDate
Presents the user with a UIDatePicker, allowing them to select a date/time.

By default this allows any date after the current date, at 5-minute intervals, with no maximum. It is possible to alter this when initialising a DataEntryFormDate without having to touch the UIDatePicker directly.


## DataEntryFormController
The purpose of a DataEntrySetupController is to allow for easy presentation of multiple DataEntrySetups, without having to present each one manually. The DataEntrySetupControllerDelegate has to conform to all of the DataEntrySetupDelegate methods.
