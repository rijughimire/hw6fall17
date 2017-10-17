require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'Should call the method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('When Harry Met Sally').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'When Harry Met Sally'}
    end
    it 'Should check for search terms that are not valid' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to '/movies' 
    end
    it 'Should render the Search Results template' do
      allow(Movie).to receive(:find_in_tmdb).and_return([1,2,3])
      post :search_tmdb, {:search_terms => 'When Harry Met Sally'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'Should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'When Harry Met Sally'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    it 'Should make the search terms available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'When Harry Met Sally'}
      expect(assigns(:search_terms)).to eq('When Harry Met Sally')
    end
    it 'Should show no matching movies if nothing is found on TMDb' do
      post :search_tmdb, {:search_terms => 'strugfsdvgbijsndu'}
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to eq("No matching movies were found on TMDb")
    end
  end
  
  describe 'Add movies to TMDb' do
    it 'Should return to the movies page if no movie was selected' do
      @fake_results = [double('movie1'), double('movie2')]
      post :add_tmdb, {}
      expect(flash[:notice]).to eq("No movies selected")
      expect(response).to redirect_to(movies_path)
    end
    it 'Should call the model method that creates the Tmdb Movie' do
      @fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:create_from_tmdb).with("999")
      expect(Movie).to receive(:create_from_tmdb).with("444")
      expect(Movie).to receive(:create_from_tmdb).with("000")
      post :add_tmdb, {"tmdb_movies" => {"999" => "1", "444" => "1", "000" => "1"}}
      expect(flash[:notice]).to eq("Movies successfully added to Rotten Potatoes")
    end
  end
end