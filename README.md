# CoreDataHelper

Swift Package for CoreData

Simplify CoreData initialization and manipulations.

## Installation
Navigate Xcode to `File > Swift Packages > Add Package dependency`.

Select <Project Name> and press next. 
Add `https://github.com/jffuriscal/CoreDataHelper.git` in the textfield for repository url.

## Usage
Recommended initialization in AppDelegate's `application(_ application:, didFinishLaunchingWithOptions:) `.
Replace `coredata_name` with the name of the file with `.xcdatamodeld`.
```
import CoreDataHelper

if #available(iOS 10.0, *) {
    ObjectManager.shared.setCoreDataModelV2(persistentContainer)
} else {
    ObjectManager.shared.setCoreDataModel(name: "coredata_name")
}
```

After initialization, usage are as follows:

Product is a subclass of NSManagedObject.

```
import CoreDataHelper


ObjectManager.shared.getAll(ofType: Product.self)
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
