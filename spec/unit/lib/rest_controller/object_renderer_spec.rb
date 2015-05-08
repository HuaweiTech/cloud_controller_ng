require 'spec_helper'

module VCAP::CloudController::RestController
  describe ObjectRenderer do
    subject(:renderer) { described_class.new(eager_loader, serializer, renderer_opts) }
    let(:eager_loader) { SecureEagerLoader.new }
    let(:serializer) { PreloadedObjectSerializer.new }
    let(:collection_transformer) { nil }
    let(:renderer_opts) do
      {
         max_inline_relations_depth: 100_000,
         collection_transformer: collection_transformer
      }
    end

    describe '#render_json' do
      let(:controller) { VCAP::CloudController::TestModelSecondLevelsController }
      let(:opts) { {} }

      let(:instance) { VCAP::CloudController::TestModelSecondLevel.make }

      context 'when asked inline_relations_depth is more than max inline_relations_depth' do
        before { renderer_opts.merge!(max_inline_relations_depth: 10) }
        before { opts.merge!(inline_relations_depth: 11) }

        it 'raises BadQueryParameter error' do
          expect {
            subject.render_json(controller, instance, opts)
          }.to raise_error(VCAP::Errors::ApiError, /inline_relations_depth/)
        end
      end

      context 'when asked inline_relations_depth equals to max inline_relations_depth' do
        before { renderer_opts.merge!(max_inline_relations_depth: 10) }
        before { opts.merge!(inline_relations_depth: 10) }

        it 'renders json response' do
          result = subject.render_json(controller, instance, opts)
          expect(result).to be_instance_of(String)
        end
      end

      context 'when asked inline_relations_depth is less than max inline_relations_depth' do
        before { renderer_opts.merge!(max_inline_relations_depth: 10) }
        before { opts.merge!(inline_relations_depth: 9) }

        it 'renders json response' do
          result = subject.render_json(controller, instance, opts)
          expect(result).to be_instance_of(String)
        end
      end

      context 'when collection_transformer is given' do
        let(:collection_transformer) { double('collection_transformer') }

        it 'passes the populated dataset to the transformer' do
          expect(collection_transformer).to receive(:transform) do |collection|
            expect(collection).to eq(instance)
          end

          subject.render_json(controller, instance, opts)
        end
      end
    end
  end
end
