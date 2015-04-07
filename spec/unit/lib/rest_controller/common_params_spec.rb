require 'spec_helper'

module VCAP::CloudController::RestController
  describe CommonParams do
    let(:logger) do
      double('Logger').as_null_object
    end
    let(:params) { {} }
    let(:env) { {} }
    let(:sinatra) { nil }
    let(:dependencies) { { object_renderer: nil, collection_renderer: nil } }
    let(:controller) { VCAP::CloudController::TestModelsController.new(double(:config), logger, env, params, double(:body), sinatra, dependencies) }

    subject(:common_params) do
      CommonParams.new(logger)
    end

    describe '#parse' do
      it 'treats inline-relations-depth as an Integer and symbolizes the key' do
        expect(common_params.parse(controller, { 'inline-relations-depth' => '123' })).to eq({ inline_relations_depth: 123 })
      end

      it 'treats orphan-relations as an Integer and symbolizes the key' do
        expect(common_params.parse(controller, { 'orphan-relations' => '1' })).to eq({ orphan_relations: 1 })
      end

      it 'treats exclude-relations as a String Array and symbolizes the key' do
        expect(common_params.parse(controller, { 'exclude-relations' => 'name1,name2' })).to eq({ exclude_relations: ['name1', 'name2'] })
      end

      it 'treats include-relations as a String Array and symbolizes the key' do
        expect(common_params.parse(controller, { 'include-relations' => 'name1,name2' })).to eq({ include_relations: ['name1', 'name2'] })
      end

      it 'treats order-by as a String Array and symbolizes the key' do
        expect(common_params.parse(controller, { 'order-by' => 'unique_value,created_at' })).to eq({ order_by: ['unique_value', 'created_at'] })
      end

      it 'treats page as an Integer and symbolizes the key' do
        expect(common_params.parse(controller, { 'page' => '123' })).to eq({ page: 123 })
      end
      it 'treats results-per-page as an Integer and symbolizes the key' do
        expect(common_params.parse(controller, { 'results-per-page' => '123' })).to eq({ results_per_page: 123 })
      end

      it 'treats q as a String and symbolizes the key' do
        expect(common_params.parse(controller, { 'q' => '123' })).to eq({ q: '123' })
      end

      it 'treats order direction as a String and symbolizes the key' do
        expect(common_params.parse(controller, { 'order-direction' => '123' })).to eq({ order_direction: '123' })
      end

      it 'discards other params' do
        expect(common_params.parse(controller, { 'foo' => 'bar' })).to eq({})
      end

      it 'handles multiple q params' do
        expect(common_params.parse(controller, { 'q' => 'a' }, 'q=a&q=b')).to eq({ q: ['a', 'b'] })
      end

      context 'when order-by include non query parameter' do
        it 'raises an error which makes sense to an api client' do
          expect { common_params.parse(controller, { 'order-by' => 'unique_value,non_query_parameter' }) }.to raise_error(VCAP::Errors::ApiError)
        end
      end
    end
  end
end
