package com.example

import io.quarkus.security.identity.SecurityIdentity
import javax.ws.rs.GET
import javax.ws.rs.Path
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType


@Path("/hello")
class ExampleResource(private val identity: SecurityIdentity) {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    fun hello() : String {
        println(identity.principal.name)
        return "Hello"
    }
}