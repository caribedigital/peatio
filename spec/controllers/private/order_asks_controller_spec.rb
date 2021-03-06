# encoding: UTF-8
# frozen_string_literal: true

describe Private::OrderAsksController, type: :controller do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: '20')
    end
  end
  before(:each) { inject_authorization!(member) }

  let(:market) { Market.find(:btcusd) }
  let(:params) do
    { market_id: market.id,
      market:    market.id,
      ask:       market.base_unit,
      bid:       market.quote_unit,
      order_ask: { ord_type: 'limit', origin_volume: '12.13', price: '2014.47' } }
  end

  context 'POST :create' do
    it 'should create a sell order' do
      expect do
        post :create, params, member_id: member.id
        expect(response).to be_success
        expect(response.body).to eq '{"result":true,"message":"Success"}'
      end.to change(OrderAsk, :count).by(1)
    end
  end

  context 'POST :clear' do
    it 'should cancel all my asks in current market' do
      o1 = create(:order_ask, member: member, market: market)
      o2 = create(:order_ask, member: member, market: Market.find(:dashbtc))
      expect(member.orders.size).to eq 2

      post :clear, { market_id: market.id }, member_id: member.id
      expect(response).to be_success
      expect(assigns(:orders).size).to eq 1
      expect(assigns(:orders).first).to eq o1
    end
  end
end
