# AkakceCase (iOS Version)

This is the **SwiftUI** implementation of the Akakce Case study, showcasing:
- **Featured Products** in a horizontal pager (first 5 items, 2 per page).
- **All Products** in a vertical grid layout.
- Data fetched from the [Fake Store API](https://fakestoreapi.com) with a clean MVVM structure.
- Unit tests for `ProductViewModel` to verify data fetching and chunking logic.

---

## Features
- **Featured Products Carousel**:  
  Displays the first 5 products from the API, chunked into pages of 2.
- **All Products Grid**:  
  Remaining products are displayed in a vertical 2-column grid.
- **Clean UI**:  
  White cards, price and rating displayed for each product.
- **Swift Concurrency**:  
  `async/await` used for API calls.
- **Unit Tested**:  
  `ProductViewModelTests` verify logic without relying on real network calls.
