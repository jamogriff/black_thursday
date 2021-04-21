## Iteration 4 Method Description

### most_sold_item_for_merchant(merchant_id)
- Pass `merchant_id` into method, and return all of merchant's invoices (`invoices`).
- Check that invoices had successful transactions; only return the invoices where true (`validated_invoices`).
- Iterate over `validated_invoices` to return `invoice_items` and pull the quantity
- Iterate over `invoice_items` and find associated `items`; use hash data structure to store items and total quantity sold by that merchant {`item` => `quantity sold in validated invoices`} 
- Iterate through this hash to find item with maximum quantity sold, like so: 
  ```
    def largest_hash_key(hash)
      hash.max_by{|k,v| v}
    end
  ```

### best_item_for_merchant(merchant_id)

sales_analyst.best_item_for_merchant(merchant_id) #=> item (in terms of revenue generated)
The first thing the we would do to figure out best item for merchant is pass in a merchant id. This would find all the invoices belonging to that merchant. We would iterate through that invoice data set, and check that its corresponding transaction was successful. If the transaction is successful, then we would look at all of the invoice items and create a hash that uses their item id as the hash key and the quantity as the value. We would also look into item repository and pull out the unit price and add that information to the corresponding item id key. This would create a nested hash. The outermost key would be the item id and the value would consist of another hash with two key value pairs. One would be its quantity and the other would be unit price. We would then make a helper method that looks at all of the data and math everything up and provide us with a final "best" number. This number would be found by using max_by enumerable. THEN BAM, DONE. 

