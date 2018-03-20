//
//  Evento.swift
//  EuskoEvents
//
//  Created by Ion Jaureguialzo Sarasola on 27/12/17.
//  Copyright © 2017 Asier. All rights reserved.
//

import Foundation

struct Evento: Comparable {

    static func < (lhs: Evento, rhs: Evento) -> Bool {
        return lhs.fechaInicio < rhs.fechaInicio
    }

    static func == (lhs: Evento, rhs: Evento) -> Bool {
        return lhs.tipo == rhs.tipo &&
            lhs.causa == rhs.causa &&
            lhs.latitud == rhs.latitud &&
            lhs.longitud == rhs.longitud &&
            lhs.fechaInicio == rhs.fechaInicio
    }

    var tipo: String
    var causa: String
    var nivel: String
    var carretera: String
    var fechaInicio: Date
    var latitud: Double?
    var longitud: Double?

}
