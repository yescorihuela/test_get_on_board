require 'minitest/autorun'

class PointOnSaleTest < Minitest::Test
  def test_six_pack_and_one_total
    terminal = PointOnSale.new
    terminal.read_all_products_from_once('CCCCCCC')
    assert terminal.total == 7.25
  end

  def test_four_products
    terminal = PointOnSale.new
    terminal.read_all_products_from_once('ABCD')
    assert terminal.total == 15.40
  end

  def test_half_purchase
    terminal = PointOnSale.new
    terminal.read_all_products_from_once('ABCDABAA')
    assert terminal.total == 32.40
  end

  def test_whole_sale
    terminal = PointOnSale.new
    terminal.read_all_products_from_once('ABBBBCCCCCCAAAAAAAAAAAAAAADDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCCCCCCCCCCCCC')
    assert terminal.total != 100.00
  end

  def test_check_purchase_order
    terminal = PointOnSale.new
    terminal.read_all_products_from_once('ABBBBCCCCCCAAAAAAAAAAAAAAADDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCCCCCCCCCCCCC')
    assert terminal.order != 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDAAAAAAAAAAAAAAACCCCCCBBBBA'
  end

  def test_check_purchase_total
    terminal = PointOnSale.new
    terminal.read_all_products_from_once('ABBBBCCCCCCAAAAAAAAAAAAAAADDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCCCCCCCCCCCCC')
    assert terminal.total == 113.85
  end

end


class PointOnSale

  attr_accessor :products, :order

  PRODUCT_PRICES = {
    A: 2.00,
    B: 12.00,
    C: 1.25,
    D: 0.15
  }

  DISCOUNTED_PRODUCTS = {
    A: { price: 7.00, by_pack: 4},
    C: { price: 6.00, by_pack: 6},
  }


  def initialize()
    @products = {
      A: [],
      B: [],
      C: [],
      D: [],
    }
    @order = []
  end

  def scan(product)
    @order << product
    @products[product.to_sym] << PRODUCT_PRICES[product.to_sym]
  end

  def total
    subtotal = 0
    @products.keys.each do |product|
      if DISCOUNTED_PRODUCTS.has_key?(product.to_sym)
        by_pack = DISCOUNTED_PRODUCTS[product][:by_pack]
        discounted_price = DISCOUNTED_PRODUCTS[product.to_sym][:price]
        @products[product].each_slice(by_pack) do |pack|
          subtotal += pack.count != by_pack ? (pack.count * PRODUCT_PRICES[product.to_sym]) : discounted_price
        end
      else
        subtotal += PRODUCT_PRICES[product.to_sym] * @products[product.to_sym].count
      end
    end
    subtotal
  end

  def get_product_order_to_bill
    @order.join
  end

  def read_all_products_from_once(products = '')
    products.chars.each{|product| scan(product)}
  end
end
