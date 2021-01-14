# SwiftCollections

Swift Collections is a package with different collections fully swift native.

Whenever possible, it uses the standard swift protocols, so they can be easily used to
substitute the estandard collections. 

Contrary to standard swift collections that are based on struct, the present ones are all
based on classes. This will require to take into account mutability aspects.

The collections availableare:

* List: List protocol based on BidirectionalCollection
* BidirectionalList: Double linked list, follows the List protocol
* CircularList: Double linked circular list, follows the List protocol
* RBDictionary: Red-Black tree based dictionary, follows the Dictionary interface,
but uses comparable keys instead of hashable
* RBSet: Red-Black tree set, follows the Set interface, but uses comparable keys instead
of hashable
