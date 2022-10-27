require "spec_helper"
require "rack/test"
require_relative '../../app' 

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end
def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end


describe Application do
  before(:each) do 
    reset_albums_table
    reset_artists_table
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "GET /" do
    it "returns the html index" do
      response = get('/')

      expect(response.body).to include '<h1>Hello!</h1>'
    end
  end

  context "GET /albums" do
    it "returns the list of albums" do
      response = get('/albums')
            
      expect(response.status).to eq 200
      expect(response.body).to include 'Doolittle'
      expect(response.body).to include 'Surfer Rosa'
    end
  end

  context "GET /albums/new" do
    it "should return a form to add a new album" do
      response = get('/albums/new')

      expect(response.status).to eq 200
      expect(response.body).to include "<form method='POST' action='/albums'>"
      expect(response.body).to include "<input type='text' name='title'/>"
      expect(response.body).to include "<input type='text' name='release_year'/>"
      expect(response.body).to include "<input type='text' name='artist_id'/>"
    end
  end

  context "GET /artists/new" do
    it "should return a form to add a new artist" do
      response = get('/artists/new')

      expect(response.status).to eq 200
      expect(response.body).to include "<form method='POST' action='/artists'/>"
      expect(response.body).to include "<input type='text' name='name'/>"
      expect(response.body).to include "<input type='text' name='genre'/>"

    end
  end

  context "GET /albums/:id" do
    it "returns the album with id 1" do
        response = get('/albums/1')

        expect(response.status).to eq 200
        expect(response.body).to include '<h1>Doolittle</h1>'
        expect(response.body).to include 'Release year: 1989'
        expect(response.body).to include 'Artist: Pixies'

    end
    it "returns the album with id 2" do
      response = get('/albums/2')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Surfer Rosa</h1>'
      expect(response.body).to include 'Release year: 1988'
      expect(response.body).to include 'Artist: Pixies'
  end
  end

  context "GET /artists/:id" do
    it "returns the artist with id 1" do
      response = get('/artists/1')

      expect(response.status).to eq 200
      expect(response.body).to include 'Pixies'
      expect(response.body).to include 'Rock'

    end
  end

  context "POST /albums" do
    it "creates an album named Voyage, release year 2022 and artist id 2" do
        response = post('/albums', title: 'Voyage', release_year: '2022', artist_id: '2')
        expect(response.status).to eq 200

        response_get = get('/albums')
        expect(response_get.status).to eq 200
        expect(response_get.body).to include 'Voyage'
    end
  end

  context "GET /artists" do
    it "returns all the artists" do
        response = get('/artists')

        expect(response.status).to eq 200
        expect(response.body).to include "Pixies" 
        expect(response.body).to include "ABBA" 
        expect(response.body).to include "Taylor Swift" 
        expect(response.body).to include "Nina Simone"
    end    
  end

  context "when user clicks on artist link" do
    it "exists as a page" do
      response = get('/artists')

      expect(response.status).to eq 200
      expect(response.body).to include '/artists/1'
    end
  end

  context "when user clicks on album link" do
    it "exists as a page" do
      response = get('/albums')

      expect(response.status).to eq 200
      expect(response.body).to include '/albums/1'

    end
  end
  

  context "POST /artists" do
  it 'adds a new artist and genre' do
    response = post('/artists', name:'Wild nothing', genre: 'Indie')
    response_get = get('/artists')

    expect(response.status).to eq(200)
    expect(response_get.body).to include('Wild nothing')
    end
  end
end


