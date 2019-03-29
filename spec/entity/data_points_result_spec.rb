# frozen_string_literal: true

RSpec.describe Hausgold::DataPointsResult do
  let(:user_id) { '96092fa8-707d-4fe6-af5e-4898b9d87a90' }
  let(:args) do
    {
      entity: "gid://maklerportal-api/User/#{user_id}",
      context: 'is24',
      metric: 'visits',
      start_at: 30.days.ago,
      end_at: 1.day.ago,
      aggregation: :sum,
      internal: :day
    }
  end
  let(:result) { Hausgold::DataPoint.query!(**args) }

  describe '#data_points_available?' do
    before { Timecop.freeze(Time.utc(2019, 3, 19, 12, 0, 0)) }

    after { Timecop.return }

    context 'with real data points present' do
      it 'detects the real data points' do
        expect(result.data_points_available?).to be(true)
      end
    end

    context 'with only gap-filling data points present' do
      let(:args) do
        {
          entity: "gid://maklerportal-api/User/#{user_id}",
          context: 'is24',
          metric: 'visits',
          start_at: 20.days.from_now,
          end_at: 21.days.from_now,
          aggregation: :sum,
          internal: :day
        }
      end

      it 'detects that no real data points are available' do
        expect(result.data_points_available?).to be(false)
      end
    end

    context 'with mixed data points (real and gap-fillers)' do
      let(:args) do
        {
          entity: "gid://maklerportal-api/User/#{user_id}",
          context: 'is24',
          metric: 'visits',
          start_at: 3.days.ago,
          end_at: 20.days.from_now,
          aggregation: :sum,
          internal: :day
        }
      end

      it 'detects the real data points are present' do
        expect(result.data_points_available?).to be(true)
      end
    end
  end
end
