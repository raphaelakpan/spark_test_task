Spree Products Import Feature
===================
This application builds an admin feature to upload products through a  CSV file.

## Features:
* Existing products (through `slug` field) are updated with the fields in the CSV
* Creates new products for rows with no matching product (`slug`)
* Runs a background job to process Products upload
* Admin can view status of upload, including error rows

![image](https://user-images.githubusercontent.com/23452546/60006936-44b5ac00-9669-11e9-9ec6-f9f38f8b35d5.png)

## Requirements
* Ruby 2.4.2
* Rails 5.1.7
* Spree 3.5
* Sidekiq 5.2.7
* Redis

## Installation

1. Clone repo:
  ```bash
  git clone git@github.com:raphaelakpan/spark_test_task.git
  cd spark_test_task
  ```

2. Install the gems:
  ```bash
  bundle install
  ```

3. Setup Database and load sample data
  ```bash
  rails db:setup # runs migration, seeds the database
  bundle exec rake spree_sample:load
  ```

5. Run Sidekiq (different terminal)
  ```bash
  bundle exec sidekiq
  ```

7. Start the server
  ```bash
  rails server
  ```

 If your server is running, navigate to `htpp://localhost:3000`

Admin route:  `htpp://localhost:3000/admin`

## CSV file format and supported attributes

| CSV column          | Product attribute      |
| ------------------- | ---------------------- |
| `name`              | `name`                 |
| `description`       | `description`          |
| `price`             | `price`                |
| `availability_date` | `available_on`         |
| `slug`              | `slug`                 |
| `stock_total`       | `master.total_on_hand` |
| `category`          | `taxons`               |

### Sample CSV file

```
;name;description;price;availability_date;slug;stock_total;category
;Ruby on Rails Bag;Animi officia aut amet molestiae atque excepturi. Placeat est cum occaecati molestiae quia. Ut soluta ipsum doloremque perferendis eligendi voluptas voluptatum.;22,99;2017-12-04T14:55:22.913Z;ruby-on-rails-bag;15;Bags
```

From the Admin Products Upload Page, you can download a sample copy.

### Specs
- Ensure test db is up current => `rails:db migrate RAILS_ENV=test`
- `rspec spec`
