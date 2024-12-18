
## AmPower OrderIT
AmPower OrderIT is a powerful app designed to streamline sales order booking for customers quickly and efficiently. With an intuitive, visually appealing interface, AmPower OrderIT offers flexible item viewing options tailored to different preferences, including catalog, grid, and list views. Each view is crafted to ensure easy navigation and enhance user experience, allowing representatives to effortlessly browse, select, and place orders quickly.

### Why AmPower OrderIT?
AmPower OrderIT is your ultimate solution for simplifying and accelerating the sales order booking process. With its user-friendly and visually appealing interface, OrderIT empowers you to efficiently handle customer orders with ease. Here's why it's the perfect choice for your business:

- **Streamlined Order Management**: Quickly browse, select, and place orders on behalf of your customers, saving time and improving productivity.
- **Flexible Viewing Options**: Whether you prefer catalog, grid, or list views, OrderIT provides multiple ways to explore items tailored to your unique needs.
- **Enhanced User Experience**: Designed with intuitive navigation and a focus on usability, OrderIT makes order booking seamless and hassle-free.
- **Efficiency at Its Core**: Boost your sales process with a tool that reduces complexity and lets you focus on what matters—your customers.

### Requirements
- **Flutter** : 3.24.2
- **ERPNext** : v15.39.3

### Tech Stack
- Frontend: Flutter
- Backend: ERPNext

### State Management Pattern
- MVVM

### Screenshots

<kbd><img width="216" height="432" src="screenshots/login.png" alt="Login" /></kbd>
<kbd><img width="216" height="432" src="screenshots/home.png" alt="Home" /></kbd>
<kbd><img width="216" height="432" src="screenshots/item_info.png" alt="Item Info" /></kbd>
<kbd><img width="216" height="432" src="screenshots/cart.png" alt="Cart" /></kbd>

### Gif

<img src="https://github.com/Ambibuzz/ampower_orderit_mobile/blob/ampower_orderit/gif/orderit_recording1.gif" alt="OrderIT GIF" width="216" height="432">

### Features of OrderIT

- Items Displayed in different views i.e list, grid, table and catalogue view
- Customer specific Pricing
- Search Items
- Place Sales Order
- Profile Screen
- Check Past Sales Orders
- Wishlist
- Cart Screen
- Stock Availability
- Favorites

### To run code
Clone the source code<br/>
```sh
git clone https://github.com/Ambibuzz/ampower_orderit_mobile.git
```
Then go to cloned directory and open project on android studio or vscode<br/>
Then checkout to master branch from terminal window of editor<br/>
```sh
git checkout master
```
For installing packages<br/>
```sh
pub packages get
```
To run the project<br/>
```sh
flutter run
```

### To deploy
Change versions in Pubspec.yaml of project.(Both version and Subversion)
```sh
version: 2.0.0+1
```
#### Android
For Building Apk
```sh
flutter build apk --release
```


#### Ios
For Building Ipa
```sh
flutter build ipa --no-tree-shake-icons
```

### Support
Encountered an issue? File a ticket on the GitHub repository.

### License
MIT