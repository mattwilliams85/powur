class IndexController < ApplicationController

	layout "landing"

	def promoter
		render layout: "signup"
	end

	def customer
	end
	
end
