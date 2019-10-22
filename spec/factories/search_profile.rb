# frozen_string_literal: true

FactoryBot.define do
  factory :search_profile, class: Hausgold::SearchProfile do
    user_id { "gid://identity-api/User/#{SecureRandom.uuid}" }
    usages do
      %i[residential commercial investment temporary_living].sample(2)
    end
    property_types do
      %i[room apartment house site office retail hospitality_industry warehouse
         agriculture parking other leisure_commercial interest_house].sample(2)
    end
    property_subtypes do
      %i[agriculture agriculture_business agriculture_forestry amusement_park
         apartment apartment_house arbor_dacha_garden_house assissted_living
         attic bar barns basement beach_house big_store boat_dock bungalow
         business business_park cafe car_park carport castle chalet club
         cold_storage convenience_store country_house detached double_garage
         duplex end_of_terrace estate exhibition_space exhibition_space
         coworking factory_building factory_outlet farm farmhouse farmstead
         finca floor forwarding_warehouse gallery gastronomy
         gastronomy_with_apartment ground_floor guesthouse hall
         high_rack_warehouse holiday_flat holiday_home horse_riding
         horticulture hospital hotels housing_area hunting_ground
         hunting_industry_and_forestry industrial_plant industry isolated_farm
         kiosk lakefront leisure leisure_facility living
         living_and_office_house maisonette manor_house mansion
         middle_of_terrace mixed mountain_shelter nursing_home office_block
         office_building office_center office_house office_space open_space
         other other_lodging palace parking_space penthouse petrol_station
         pond_and_fish_industry practice_building practice_space prefabricated
         production ranching raw_attic restaurant retail_shop room row_house
         rustico sales_area sanatorium self_service_market semi_detached
         service shared_office shop shopping_center single_garage single_room
         smokers_place special_use sports_facility storage storage_area
         storage_with_open_space studio studio practice terrace townhouse
         two_family_house underground_parking underground_parking_space
         viniculture with_charging_station workshop].sample(2)
    end
    city { 'Leipzig' }
    zipcode { '04178' }
    perimeter { [rand(5..300), Float::INFINITY].sample }
    price_from { 0 }
    price_to { [rand(90_000..350_000), Float::INFINITY].sample }
    year_of_construction_from { 0 }
    year_of_construction_to { [rand(1970..2010), Float::INFINITY].sample }
    amount_rooms_from { 0 }
    amount_rooms_to { [rand(1..5), Float::INFINITY].sample }
    living_space_from { 0 }
    living_space_to { [rand(50..150), Float::INFINITY].sample }
    land_size_from { 0 }
    land_size_to { [rand(300..2000), Float::INFINITY].sample }
    created_at { Time.zone.yesterday }
    updated_at { Time.zone.now }
  end
end
