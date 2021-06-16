# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe OrderInventory do
    subject { described_class.new(order, order.line_items.first) }

    let!(:store) { create :store }
    let(:order) { Order.create }

    context "same variant within bundle and as regular product" do
      let(:contents) { OrderContents.new(order) }
      let(:guitar) { create(:variant) }
      let(:bass) { create(:variant) }

      let(:bundle) { create(:product) }

      before { bundle.parts.push [guitar, bass] }

      let!(:bundle_item) { contents.add(bundle.master, 5) }
      let!(:guitar_item) { contents.add(guitar, 3) }

      let!(:shipment) { order.create_proposed_shipments.first }

      context "completed order" do
        before do
          order.touch :completed_at
        end

        it "removes only units associated with provided line item" do
          expect {
            subject.send(:remove_from_shipment, shipment, 5)
          }.not_to change { bundle_item.inventory_units.count }
        end
      end
    end
  end
end
